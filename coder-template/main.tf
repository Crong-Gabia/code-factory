terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable "repo_path" {
  type        = string
  description = "Absolute host path to this repository; mounted into the workspace at /workspace"
}

variable "opencode_model" {
  type        = string
  description = "Optional: OPENCODE_MODEL (provider/model). If set, opencode can run non-interactively without selecting a model."
  default     = ""
}

variable "opencode_agent" {
  type        = string
  description = "Optional: OPENCODE_AGENT (agent name). If set, opencode uses this agent by default."
  default     = ""
}

variable "openai_api_key" {
  type        = string
  description = "Optional: OPENAI_API_KEY for OpenCode provider auth via environment variables."
  default     = ""
  sensitive   = true
}

variable "anthropic_api_key" {
  type        = string
  description = "Optional: ANTHROPIC_API_KEY for OpenCode provider auth via environment variables."
  default     = ""
  sensitive   = true
}

variable "gemini_api_key" {
  type        = string
  description = "Optional: GEMINI_API_KEY for OpenCode provider auth via environment variables."
  default     = ""
  sensitive   = true
}

variable "openrouter_api_key" {
  type        = string
  description = "Optional: OPENROUTER_API_KEY for OpenCode provider auth via environment variables."
  default     = ""
  sensitive   = true
}

variable "ca_cert_pem" {
  type        = string
  description = "Optional corporate/root CA bundle in PEM format (used to trust TLS interception for docker pulls)."
  default     = ""
}

variable "ca_cert_pem_b64" {
  type        = string
  description = "Optional corporate/root CA bundle (PEM) base64-encoded. Preferred for CLI usage."
  default     = ""
}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

locals {
  username = data.coder_workspace_owner.me.name
  # Replace localhost URLs so the agent inside the container can reach the host Coder server.
  agent_init_script = replace(
    replace(coder_agent.main.init_script, "http://localhost:3001", "http://host.docker.internal:3001"),
    "http://127.0.0.1:3001",
    "http://host.docker.internal:3001",
  )

  ca_cert_pem_effective = var.ca_cert_pem != "" ? var.ca_cert_pem : (
    var.ca_cert_pem_b64 != "" ? base64decode(var.ca_cert_pem_b64) : ""
  )

  ca_cert_pem_b64_effective = var.ca_cert_pem_b64 != "" ? var.ca_cert_pem_b64 : (
    var.ca_cert_pem != "" ? base64encode(var.ca_cert_pem) : ""
  )
}

provider "coder" {}
provider "docker" {}

resource "coder_agent" "main" {
  arch = data.coder_provisioner.me.arch
  os   = "linux"

  env = {
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = data.coder_workspace_owner.me.email
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = data.coder_workspace_owner.me.email
  }

  startup_script = <<-EOT
    set -e
    echo "Workspace ready. Repo mounted at /workspace"
    echo "Docker daemon for compose is provided by dind sidecar via DOCKER_HOST."
    echo
    # Forward localhost:3000 -> dind:3000 so curl localhost works in the workspace.
    # This is a best-effort helper; if api isn't up yet, it will keep retrying.
    (
      while true; do
        if command -v socat >/dev/null 2>&1 && [ -n "$${DIND_HOST:-}" ]; then
          socat -d -d TCP-LISTEN:3000,fork,reuseaddr TCP:$${DIND_HOST}:3000 || true
        fi
        sleep 1
      done
    ) >/tmp/port-forward-3000.log 2>&1 &

    # Optional: set up OpenCode + Oh My OpenCode worker.
    if [ -x /workspace/scripts/workspace/setup-opencode.sh ]; then
      /workspace/scripts/workspace/setup-opencode.sh || true
    fi
  EOT
}

resource "docker_network" "private_network" {
  name = "coder-net-${data.coder_workspace.me.id}"
}

resource "docker_container" "dind" {
  image      = "docker:27-dind"
  privileged = true
  name       = "dind-${data.coder_workspace.me.id}"

  env = [
    "CA_CERT_PEM=${local.ca_cert_pem_effective}",
  ]

  entrypoint = [
    "sh",
    "-lc",
    "set -e; if [ -n \"$CA_CERT_PEM\" ]; then apk add --no-cache ca-certificates >/dev/null; echo \"$CA_CERT_PEM\" >/usr/local/share/ca-certificates/corp.crt; update-ca-certificates >/dev/null; fi; exec dockerd -H tcp://0.0.0.0:2375",
  ]

  networks_advanced {
    name = docker_network.private_network.name
  }

  # Enable bind mounts from the workspace path when using this dind daemon.
  # docker compose runs in the workspace container and will send absolute paths like
  # /workspace/... to the daemon. Those paths must exist on the daemon host (this dind container).
  volumes {
    host_path      = var.repo_path
    container_path = "/workspace"
    read_only      = false
  }
}

resource "docker_image" "workspace" {
  name = "coder-workspace-${data.coder_workspace.me.id}"
  build {
    context = "./build"
    build_args = {
      USER = local.username
    }
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
  }
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count

  image    = docker_image.workspace.name
  name     = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  hostname = data.coder_workspace.me.name

  command = [
    "sh",
    "-lc",
    <<-EOT
      set -e
      if [ -n "$CA_CERT_PEM" ]; then
        sudo mkdir -p /usr/local/share/ca-certificates
        printf '%s\n' "$CA_CERT_PEM" | sudo tee /usr/local/share/ca-certificates/corp.crt >/dev/null
        sudo update-ca-certificates >/dev/null || true
      fi
      sh -lc '${replace(local.agent_init_script, "'", "'\\''")}'
    EOT
  ]

  env = concat(
    [
      "CODER_AGENT_TOKEN=${coder_agent.main.token}",
      "DOCKER_HOST=tcp://${docker_container.dind.name}:2375",
      "DIND_HOST=${docker_container.dind.name}",
      "CA_CERT_PEM=${local.ca_cert_pem_effective}",
      "CA_CERT_PEM_B64=${local.ca_cert_pem_b64_effective}",
    ],
    var.opencode_model != "" ? ["OPENCODE_MODEL=${var.opencode_model}"] : [],
    var.opencode_agent != "" ? ["OPENCODE_AGENT=${var.opencode_agent}"] : [],
    var.openai_api_key != "" ? ["OPENAI_API_KEY=${var.openai_api_key}"] : [],
    var.anthropic_api_key != "" ? ["ANTHROPIC_API_KEY=${var.anthropic_api_key}"] : [],
    var.gemini_api_key != "" ? ["GEMINI_API_KEY=${var.gemini_api_key}"] : [],
    var.openrouter_api_key != "" ? ["OPENROUTER_API_KEY=${var.openrouter_api_key}"] : [],
  )

  networks_advanced {
    name = docker_network.private_network.name
  }

  # For Linux engines, ensure host.docker.internal resolves.
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    host_path      = var.repo_path
    container_path = "/workspace"
    read_only      = false
  }
}

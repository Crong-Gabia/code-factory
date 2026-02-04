#!/usr/bin/env bash
set -euo pipefail

# Run INSIDE the Lume macOS VM.
# - Prompts once for API keys and stores in the VM Keychain
# - Starts OpenCode Web UI on VM (localhost:4096)
# - No secrets are baked into the golden image

SERVICE_PREFIX="code-factory.opencode"

log() { echo "[vm-opencode-web] $*"; }
warn() { echo "[vm-opencode-web][WARN] $*" >&2; }
die() { echo "[vm-opencode-web][FAIL] $*" >&2; exit 1; }

read_keychain() {
  local name="$1"
  security find-generic-password -a "$USER" -s "${SERVICE_PREFIX}.${name}" -w 2>/dev/null || true
}

write_keychain() {
  local name="$1"
  local value="$2"
  security add-generic-password -U -a "$USER" -s "${SERVICE_PREFIX}.${name}" -w "$value" >/dev/null
}

prompt_secret() {
  local label="$1"
  local val=""
  echo -n "$label: " >&2
  IFS= read -rs val
  echo "" >&2
  echo "$val"
}

ensure_key() {
  local env_name="$1"
  local kc_name="$2"

  if [[ -n "${!env_name:-}" ]]; then
    return 0
  fi

  local kc_val
  kc_val="$(read_keychain "$kc_name")"
  if [[ -n "$kc_val" ]]; then
    export "$env_name=$kc_val"
    return 0
  fi

  echo "" >&2
  echo "[$env_name] not found. One-time setup (stored in VM Keychain):" >&2
  local input
  input="$(prompt_secret "Enter $env_name")"
  [[ -n "$input" ]] || die "$env_name is required"
  write_keychain "$kc_name" "$input"
  export "$env_name=$input"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script must run on macOS (inside Lume VM). Detected: $(uname -s)"
fi

ensure_key "OPENAI_API_KEY" "OPENAI_API_KEY"
ensure_key "GEMINI_API_KEY" "GEMINI_API_KEY"

if ! command -v opencode >/dev/null 2>&1; then
  warn "opencode not found. Run ~/cua-pilot/vm-bootstrap.sh first."
  exit 1
fi

log "Initializing opencode config (oh-my-opencode)"
oh-my-opencode install --no-tui --skip-auth --openai=yes --gemini=yes --claude=no --copilot=no --opencode-zen=yes --zai-coding-plan=no

log "Starting OpenCode Web UI"
log "- URL (inside VM browser): http://localhost:4096"

exec opencode web --hostname 127.0.0.1 --port 4096

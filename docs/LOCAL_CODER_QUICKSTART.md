# LOCAL Coder Quickstart (macOS + Local Coder Binary + Docker Workspace)

## Goal (Success Criteria)

Host macOS:
- `coder server` is running as a local binary
- Browser opens `http://localhost:3001`
- Template is registered via `coder templates push`

Coder Workspace:
- Workspace starts successfully (Docker-based)
- Inside workspace, this repo's boilerplate runs:
  - `docker compose up --build -d`
  - `curl -fsS http://localhost:3000/health` returns 200
  - `docker compose run --rm api npm run verify` passes

## Prerequisites

- macOS
- Docker Desktop installed and running
- Host port 3000 is free (Coder server binds `:3000`)

## 0) Check prerequisites

```bash
bash scripts/check-prereqs.sh
```

## End-to-end demo

This script attempts to:
- start Docker Desktop (if needed)
- install `coder` CLI (if missing)
- start the Coder server on `http://localhost:3001`

```bash
bash scripts/demo-e2e.sh
```

## Troubleshooting notes (real issues we hit)

- Apple Silicon: Coder server needs an external PostgreSQL.
  - This repo starts Postgres via Docker: `bash scripts/start-postgres.sh`
  - It writes `.coder/postgres.env`

- CLI auth vs UI auth:
  - `coder templates push` requires `coder login http://localhost:3001`.

- Terraform template parse error (`Extra characters after interpolation...`):
  - Caused by bash `${VAR:-}` inside `main.tf`.
  - Fixed by escaping as `$${VAR:-}`.

- Workspace terminal stuck at `Trying to connect...` (502):
  - Agent inside container was trying to reach Coder server via `localhost`.
  - Template replaces it with `host.docker.internal` + `host-gateway` mapping.

- Workspace image build failure:
  - `docker-compose-plugin` not available on Ubuntu 24.04 arm64.
  - External HTTPS downloads can fail with corporate/self-signed TLS.
  - Fixed by using `docker-compose-v2` and multi-stage Node copy.

## Workspace Docker pull TLS error

Symptom:
- Inside the workspace, `docker compose up` fails pulling images with:
  - `tls: failed to verify certificate: x509: certificate signed by unknown authority`

Cause:
- Corporate TLS interception / custom CA. The workspace Docker daemon (dind) does not trust the CA.

Fix (recommended): inject corporate CA into the template

Preferred: pass base64-encoded PEM as a single CLI variable (`ca_cert_pem_b64`).

```bash
CERT_PATH="/Users/crong/Desktop/Crong(조희권)/Gabia Inc..cer"
CA_B64="$(openssl x509 -in "$CERT_PATH" -inform DER -outform PEM | base64 | tr -d '\n')"

coder templates push docker-dev-factory -d coder-template \
  --variable repo_path="/Users/crong/WebstormProjects/code-factory" \
  --variable ca_cert_pem_b64="$CA_B64" \
  --yes --ignore-lockfile
```

Then recreate the workspace or run:

```bash
coder update <workspace-name>
```

## Prisma generate build failure (Workspace)

Symptom:
- During `docker compose up --build`, Prisma engine download fails with:
  - `self-signed certificate in certificate chain`

Fix:
- This repo's API Dockerfiles accept `CA_CERT_PEM_B64` as a build arg.
- The workspace template exports `CA_CERT_PEM_B64` when you pass `ca_cert_pem_b64` while pushing the template.
- Recreate or `coder update` the workspace after updating the template.

## 1) Install Coder CLI (if needed)

Coder official install (macOS):

```bash
curl -L https://coder.com/install.sh | sh
```

## 2) Start Coder server (local binary)

```bash
bash scripts/start-coder.sh
```

Open:

- `http://localhost:3001`

Apple Silicon note:
- If you are on arm64, Coder requires an external PostgreSQL.
- This repo auto-starts Postgres via Docker using `scripts/start-postgres.sh`.

## 3) Login from CLI

```bash
coder login http://localhost:3001
```

## 4) Push the Docker workspace template

This template mounts the current repository into the workspace at `/workspace`.

```bash
bash scripts/setup-template.sh
```

## 5) Create a workspace

Follow: `scripts/create-workspace.md`

## 6) Verify the boilerplate inside the workspace

In the workspace terminal:

```bash
cd /workspace/boilerplate
docker compose up --build -d
curl -fsS http://localhost:3000/health
docker compose run --rm api npm run verify
```

User context (ingress headers) check:

```bash
curl -fsS \
  -H 'x-user-id: 123' \
  -H 'x-user-email: a@b.com' \
  -H 'x-user-roles: admin,dev' \
  http://localhost:3000/me
```

## Document-driven demo (ROADMAP triggers the process)

The demo flow is:

1) Change `ROADMAP.md` (mark one step as `IN_PROGRESS`)
2) Run the process runner (or watch mode)

Inside the workspace:

```bash
cd /workspace/boilerplate
docker compose run --rm api npm run process
```

Watch mode:

```bash
cd /workspace/boilerplate
docker compose run --rm api npm run process:watch
```

Ports:
- `http://localhost:3001` is the Coder server UI
- `http://localhost:3000` is the boilerplate API inside the workspace

## (MVP) OpenCode worker flow

1) Generate an OpenCode prompt from the current `(IN_PROGRESS)` step:

```bash
cd /workspace/boilerplate
docker compose run --rm api npm run ai:prompt
```

Prompt file:
- `boilerplate/.ai/opencode-prompt.md`

2) Run OpenCode (opencode) and paste the prompt contents.

If OpenCode is not installed in the workspace yet:

```bash
cd /workspace
bash scripts/install-opencode.sh

# If PATH is not updated automatically
export PATH="$HOME/.opencode/bin:$PATH"
opencode --version
```

To apply the same Oh My OpenCode config as your host:

On host macOS:

```bash
bash scripts/sync-oh-my-opencode-config.sh "$HOME/.config/opencode/oh-my-opencode.json"
```

Then recreate/update the workspace. The template startup script will attempt to run:

- `/workspace/scripts/workspace/setup-opencode.sh`

Manual inside workspace:

```bash
bash /workspace/scripts/workspace/setup-opencode.sh
```

3) Run the quality gate after changes:

```bash
docker compose run --rm api npm run verify
```

Notes:
- The workspace template runs an internal Docker daemon (dind) and sets `DOCKER_HOST` automatically.
- The template also forwards `localhost:3000` inside the workspace to the API container port so the curl command works without colliding with the host Coder server.

## Self-signed certificate

If Node tooling fails with:

`self signed certificate in certificate chain`

### Temporary (NOT recommended)

```bash
NODE_TLS_REJECT_UNAUTHORIZED=0 npm install
```

### Recommended: provide your CA bundle

1) Export your corporate/root CA as a PEM file, e.g. `~/corp-ca.pem`
2) Run Node with:

```bash
export NODE_EXTRA_CA_CERTS="$HOME/corp-ca.pem"
node -e "https=require('https');https.get('https://example.com',r=>console.log(r.statusCode))"
```

### macOS Keychain (Always Trust)

1) Open `Keychain Access`
2) Import the CA certificate into `System` keychain
3) Open the cert and set `Trust` -> `When using this certificate: Always Trust`
4) Restart the terminal app, retry Node tooling

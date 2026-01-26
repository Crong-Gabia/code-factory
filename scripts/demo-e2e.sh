#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[1/5] Ensure Docker Desktop is running"
if command -v docker >/dev/null 2>&1; then
  if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon not reachable; starting Docker Desktop..."
    open -a Docker || true
    for i in $(seq 1 90); do
      if docker info >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done
  fi
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon still not reachable. Start Docker Desktop manually and retry." >&2
  exit 1
fi

echo "[2/5] Ensure coder CLI is installed"
if ! command -v coder >/dev/null 2>&1; then
  echo "Installing coder CLI (may prompt for permissions depending on your system)..."
  curl -L https://coder.com/install.sh | sh
fi

if ! command -v coder >/dev/null 2>&1; then
  echo "coder CLI still not found on PATH. Re-open your terminal or add install location to PATH." >&2
  exit 1
fi

echo "[3/5] Check prerequisites (port 3001 etc.)"
bash "$ROOT_DIR/scripts/check-prereqs.sh"

echo "[3.5/5] Apple Silicon: ensure Postgres for Coder"
if [[ "$(uname -m)" == "arm64" ]]; then
  bash "$ROOT_DIR/scripts/start-postgres.sh" >/dev/null
  if [[ -f "$ROOT_DIR/.coder/postgres.env" ]]; then
    # shellcheck disable=SC1091
    source "$ROOT_DIR/.coder/postgres.env"
  fi
fi

echo "[4/5] Start Coder server on http://localhost:3001"
mkdir -p "$ROOT_DIR/.coder"
LOG_FILE="$ROOT_DIR/.coder/coder-server.log"

if lsof -nP -iTCP:3001 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port 3001 is already in use; stop the process and retry." >&2
  lsof -nP -iTCP:3001 -sTCP:LISTEN || true
  exit 1
fi

nohup bash "$ROOT_DIR/scripts/start-coder.sh" >"$LOG_FILE" 2>&1 &
CODER_PID=$!
echo "Coder server PID: $CODER_PID"
echo "Logs: $LOG_FILE"

for i in $(seq 1 30); do
  if curl -fsS "http://localhost:3001" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo "Open in browser: http://localhost:3001"
echo
echo "[5/5] Login + push template + create workspace"
echo "1) Login (CLI): coder login http://localhost:3001"
echo "2) Push template: bash scripts/setup-template.sh"
echo "3) Create workspace: see scripts/create-workspace.md"

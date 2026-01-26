#!/usr/bin/env bash
set -euo pipefail

status=0

fail() {
  echo "[FAIL] $1" >&2
  status=1
}

warn() {
  echo "[WARN] $1" >&2
}

ok() {
  echo "[OK] $1"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  warn "This runbook targets macOS. Detected: $(uname -s)"
else
  ok "macOS detected"
fi

if ! command -v docker >/dev/null 2>&1; then
  fail "docker not found. Install Docker Desktop first."
else
  ok "docker CLI found"
fi

if lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  warn "Port 3000 is currently in use. The boilerplate API uses :3000 by default."
  echo "---"
  lsof -nP -iTCP:3000 -sTCP:LISTEN || true
  echo "---"
fi

if lsof -nP -iTCP:3001 -sTCP:LISTEN >/dev/null 2>&1; then
  warn "Port 3001 is currently in use. Coder server must bind :3001 (per this repo's runbook)."
  echo "---"
  lsof -nP -iTCP:3001 -sTCP:LISTEN || true
  echo "---"
  fail "Free port 3001 (stop the process) then retry."
else
  ok "Port 3001 available"
fi

if ! command -v coder >/dev/null 2>&1; then
  warn "coder CLI not found. Install with: curl -L https://coder.com/install.sh | sh"
  fail "Install coder CLI and retry."
else
  ok "coder CLI found"
fi

if command -v docker >/dev/null 2>&1; then
  if ! docker info >/dev/null 2>&1; then
    warn "Docker daemon not reachable. Attempting to start Docker Desktop..."
    if command -v open >/dev/null 2>&1; then
      open -a Docker || true
    fi
    for i in $(seq 1 60); do
      if docker info >/dev/null 2>&1; then
        ok "Docker daemon reachable"
        break
      fi
      sleep 1
    done
    if ! docker info >/dev/null 2>&1; then
      fail "Docker daemon not reachable. Start Docker Desktop and retry."
    fi
  else
    ok "Docker daemon reachable"
  fi
fi

echo
echo "Notes:"
echo "- If you hit 'self signed certificate in certificate chain' when using Node tools, see docs/LOCAL_CODER_QUICKSTART.md#self-signed-certificate." 

exit "$status"

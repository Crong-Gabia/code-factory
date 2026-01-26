#!/usr/bin/env bash
set -euo pipefail

if ! command -v coder >/dev/null 2>&1; then
  echo "coder CLI not found. Install with:" >&2
  echo "  curl -L https://coder.com/install.sh | sh" >&2
  exit 1
fi

exec_coder() {
  local postgres_url="$1"
  local help
  help="$(coder server --help 2>&1 || true)"

  local args=("server")
  if [[ -n "$postgres_url" ]]; then
    args+=("--postgres-url=${postgres_url}")
  fi

  # Prefer supported flags if present.
  if [[ "$help" == *"--http-address"* ]]; then
    args+=("--http-address" "127.0.0.1:3001")
  fi
  if [[ "$help" == *"--access-url"* ]]; then
    args+=("--access-url" "http://localhost:3001")
  fi

  exec coder "${args[@]}"
}

if lsof -nP -iTCP:3001 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port 3001 is already in use. Stop the process and retry:" >&2
  lsof -nP -iTCP:3001 -sTCP:LISTEN || true
  exit 1
fi

ARCH="$(uname -m)"

echo "Starting Coder server (local binary) on http://localhost:3001"
echo

if [[ "$ARCH" == "arm64" ]]; then
  # Coder docs: Apple Silicon requires external Postgres.
  if [[ -z "${CODER_POSTGRES_URL:-}" ]]; then
    echo "Apple Silicon detected (arm64). Starting Postgres via Docker..." >&2
    bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/start-postgres.sh" >&2
    if [[ -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.coder/postgres.env" ]]; then
      # shellcheck disable=SC1091
      source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.coder/postgres.env"
    fi
  fi

  exec_coder "$CODER_POSTGRES_URL"
else
  exec_coder ""
fi

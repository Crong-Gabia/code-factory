#!/usr/bin/env bash
set -euo pipefail

# Postgres for local Coder server on Apple Silicon.
# Runs Postgres in Docker so you don't need Homebrew Postgres.

PG_CONTAINER_NAME="${PG_CONTAINER_NAME:-coder-postgres}"
PG_IMAGE="${PG_IMAGE:-postgres:16}"
PG_PORT="${PG_PORT:-5432}"
PG_USER="${PG_USER:-coder}"
PG_PASSWORD="${PG_PASSWORD:-coder}"
PG_DB="${PG_DB:-coder}"
PG_VOLUME="${PG_VOLUME:-coder_pgdata}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT_DIR/.coder"
ENV_FILE="$STATE_DIR/postgres.env"

is_port_free() {
  local port="$1"
  ! lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1
}

pick_port() {
  local preferred="$1"
  if is_port_free "$preferred"; then
    echo "$preferred"
    return 0
  fi
  for p in $(seq 5433 5442); do
    if is_port_free "$p"; then
      echo "$p"
      return 0
    fi
  done
  echo "" 
  return 1
}

get_container_host_port() {
  local name="$1"
  # Example output: "127.0.0.1:5433" or "0.0.0.0:5433"
  local line
  line="$(docker port "$name" 5432/tcp 2>/dev/null | head -n 1 || true)"
  if [[ -z "$line" ]]; then
    echo ""
    return 1
  fi
  echo "$line" | sed 's/.*://'
}

echo "Ensuring Postgres is running (Docker): ${PG_CONTAINER_NAME}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found. Install Docker Desktop first." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon not reachable. Start Docker Desktop and retry." >&2
  exit 1
fi

mkdir -p "$STATE_DIR"

if docker ps --format '{{.Names}}' | grep -qx "$PG_CONTAINER_NAME"; then
  mapped="$(get_container_host_port "$PG_CONTAINER_NAME" || true)"
  if [[ -n "$mapped" ]]; then
    PG_PORT="$mapped"
  fi
  echo "Postgres container already running on host port: ${PG_PORT}"
else
  PG_PORT="$(pick_port "$PG_PORT")"
  if [[ -z "$PG_PORT" ]]; then
    echo "No free port available for Postgres (tried 5432, 5433-5442)." >&2
    exit 1
  fi
  echo "Using host port: $PG_PORT"
fi

if docker ps --format '{{.Names}}' | grep -qx "$PG_CONTAINER_NAME"; then
  :
else
  if docker ps -a --format '{{.Names}}' | grep -qx "$PG_CONTAINER_NAME"; then
    echo "Starting existing Postgres container..."
    if ! docker start "$PG_CONTAINER_NAME" >/dev/null 2>&1; then
      echo "Failed to start existing Postgres container. Recreating..." >&2
      docker rm -f "$PG_CONTAINER_NAME" >/dev/null 2>&1 || true
      docker volume create "$PG_VOLUME" >/dev/null
      docker run -d \
        --name "$PG_CONTAINER_NAME" \
        -e POSTGRES_USER="$PG_USER" \
        -e POSTGRES_PASSWORD="$PG_PASSWORD" \
        -e POSTGRES_DB="$PG_DB" \
        -p "127.0.0.1:${PG_PORT}:5432" \
        -v "${PG_VOLUME}:/var/lib/postgresql/data" \
        --health-cmd='pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB' \
        --health-interval=2s \
        --health-timeout=2s \
        --health-retries=30 \
        "$PG_IMAGE" >/dev/null
    fi
  else
    echo "Creating Postgres container..."
    docker volume create "$PG_VOLUME" >/dev/null
    docker run -d \
      --name "$PG_CONTAINER_NAME" \
      -e POSTGRES_USER="$PG_USER" \
      -e POSTGRES_PASSWORD="$PG_PASSWORD" \
      -e POSTGRES_DB="$PG_DB" \
      -p "127.0.0.1:${PG_PORT}:5432" \
      -v "${PG_VOLUME}:/var/lib/postgresql/data" \
      --health-cmd='pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB' \
      --health-interval=2s \
      --health-timeout=2s \
      --health-retries=30 \
      "$PG_IMAGE" >/dev/null
  fi
fi

echo "Waiting for Postgres healthcheck..."
for i in $(seq 1 60); do
  status="$(docker inspect --format='{{.State.Health.Status}}' "$PG_CONTAINER_NAME" 2>/dev/null || true)"
  if [[ "$status" == "healthy" ]]; then
    echo "Postgres is healthy."
    break
  fi
  if [[ "$status" == "unhealthy" ]]; then
    echo "Postgres became unhealthy. Logs:" >&2
    docker logs --tail 50 "$PG_CONTAINER_NAME" >&2 || true
    exit 1
  fi
  sleep 1
done

if [[ "$(docker inspect --format='{{.State.Health.Status}}' "$PG_CONTAINER_NAME" 2>/dev/null || true)" != "healthy" ]]; then
  echo "Postgres did not become healthy in time. Logs:" >&2
  docker logs --tail 80 "$PG_CONTAINER_NAME" >&2 || true
  exit 1
fi

echo
CODER_POSTGRES_URL="postgres://${PG_USER}:${PG_PASSWORD}@localhost:${PG_PORT}/${PG_DB}?sslmode=disable"

cat >"$ENV_FILE" <<EOF
export CODER_POSTGRES_URL='${CODER_POSTGRES_URL}'
export CODER_POSTGRES_HOST_PORT='${PG_PORT}'
export CODER_POSTGRES_CONTAINER='${PG_CONTAINER_NAME}'
EOF

echo "Wrote: $ENV_FILE"
echo "Export this for Coder server:"
echo "  $CODER_POSTGRES_URL"

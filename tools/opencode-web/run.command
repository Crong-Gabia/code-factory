#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

SERVICE_PREFIX="code-factory.opencode"

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
  # silent input
  IFS= read -rs val
  echo "" >&2
  echo "$val"
}

ensure_key() {
  local env_name="$1"
  local kc_name="$2"

  # If user already exported env var, prefer it.
  if [[ -n "${!env_name:-}" ]]; then
    echo "$env_name is already set (env)" >&2
    return 0
  fi

  local kc_val
  kc_val="$(read_keychain "$kc_name")"
  if [[ -n "$kc_val" ]]; then
    export "$env_name=$kc_val"
    echo "$env_name loaded from macOS Keychain" >&2
    return 0
  fi

  echo "" >&2
  echo "[$env_name] not found. One-time setup:" >&2
  local input
  input="$(prompt_secret "Enter $env_name")"
  if [[ -z "$input" ]]; then
    echo "$env_name is required" >&2
    exit 1
  fi
  write_keychain "$kc_name" "$input"
  export "$env_name=$input"
  echo "$env_name saved to macOS Keychain" >&2
}

ensure_key "OPENAI_API_KEY" "OPENAI_API_KEY"
ensure_key "GEMINI_API_KEY" "GEMINI_API_KEY"

if [[ -n "${OPENROUTER_API_KEY:-}" ]]; then
  echo "OPENROUTER_API_KEY detected (optional)"
fi

mkdir -p "./empty-workspace"

echo "Building image (latest opencode/oh-my-opencode)..."
docker compose -f compose.yml build --pull

echo "Starting OpenCode Web UI..."
docker compose -f compose.yml up --pull always -d

echo "Opening browser..."
open "http://localhost:4096"

echo ""
echo "Done."
echo "- Web UI: http://localhost:4096"
echo "- Stop: docker compose -f compose.yml down"

echo ""
echo "Update to newest version (rebuild):"
echo "  docker compose -f compose.yml build --pull --no-cache"
echo ""
echo "Tip: mount a project by setting PROJECT_DIR, e.g.:"
echo "  export PROJECT_DIR=\"$HOME/work/my-repo\""

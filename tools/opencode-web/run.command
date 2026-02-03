#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "OPENAI_API_KEY is required" >&2
  exit 1
fi

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "GEMINI_API_KEY is required" >&2
  exit 1
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

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROMPT_FILE="$(bash "$ROOT_DIR/scripts/ai/generate-opencode-prompt.sh")"

echo "Generated prompt: $PROMPT_FILE"
echo
echo "Next (manual):"
echo "1) Open OpenCode (opencode) and run it against this repo." 
echo "2) Paste the prompt content from: $PROMPT_FILE" 
echo "3) After code changes, run the quality gate:" 
echo "   docker compose run --rm api npm run verify" 
echo

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROJECT_DESC_FILE="$ROOT_DIR/project_description.md"
ROADMAP_FILE="$ROOT_DIR/ROADMAP.md"
RULER_FILE="$ROOT_DIR/RULER.md"

if [[ ! -f "$PROJECT_DESC_FILE" ]]; then
  echo "project_description.md not found: $PROJECT_DESC_FILE" >&2
  exit 1
fi

if [[ ! -f "$ROADMAP_FILE" ]]; then
  echo "ROADMAP.md not found: $ROADMAP_FILE" >&2
  echo "Tip: run scripts/ai/init-plan.sh first." >&2
  exit 1
fi

if [[ ! -f "$RULER_FILE" ]]; then
  echo "RULER.md not found: $RULER_FILE" >&2
  echo "Tip: run scripts/ai/init-plan.sh first." >&2
  exit 1
fi

PROMPT_FILE="$(bash "$ROOT_DIR/scripts/ai/generate-opencode-prompt.sh")"

echo "Generated task prompt: $PROMPT_FILE"

if [[ "${DRY_RUN:-}" == "1" ]]; then
  echo "DRY_RUN=1 set; skipping opencode run."
  exit 0
fi

if ! command -v opencode >/dev/null 2>&1; then
  echo "opencode not found. Install it or run workspace setup." >&2
  exit 1
fi

args=(run)
if [[ -n "${OPENCODE_MODEL:-}" ]]; then
  args+=(--model "$OPENCODE_MODEL")
fi
if [[ -n "${OPENCODE_AGENT:-}" ]]; then
  args+=(--agent "$OPENCODE_AGENT")
fi

args+=(
  -f "$PROMPT_FILE"
  -f "$PROJECT_DESC_FILE"
  -f "$ROADMAP_FILE"
  -f "$RULER_FILE"
)

# IMPORTANT:
# - Send the prompt message via STDIN to avoid argv mis-parsing as a file path.
cat <<'EOF' | opencode "${args[@]}"
ULTRAWORK MODE ENABLED!
Implement the current ROADMAP (IN_PROGRESS) step described in the attached prompt.
EOF

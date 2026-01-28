#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROJECT_DESC_FILE="$ROOT_DIR/project_description.md"
OUT_DIR="$ROOT_DIR/.ai"
PROMPT_FILE="$OUT_DIR/opencode-init-plan.md"

if [[ ! -f "$PROJECT_DESC_FILE" ]]; then
  echo "project_description.md not found: $PROJECT_DESC_FILE" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

cat >"$PROMPT_FILE" <<'EOF'
# OpenCode Init Plan Prompt

## Goal
Turn the attached `project_description.md` into a runnable plan and project rules.

## Must Output (write files in this repo)
- `GEMINI.md`
- `AGENTS.md`
- `RULER.md`
- `ROADMAP.md`

## Requirements
- `ROADMAP.md` must contain at least 5 concrete steps.
- Exactly one step must be marked `(IN_PROGRESS)`.
- Steps must be verifiable (mention how to verify, e.g. `npm run verify`).
- Keep scope realistic for this repo (Express + MySQL + Prisma).
- Do not change application code in this phase; only create/update the docs listed above.
EOF

echo "Generated init prompt: $PROMPT_FILE"

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
  --
  "Generate the required docs using the attached prompt and project description."
)

opencode "${args[@]}"

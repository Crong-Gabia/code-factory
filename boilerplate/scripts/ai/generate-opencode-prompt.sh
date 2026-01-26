#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="$ROOT_DIR/.ai"
OUT_FILE="$OUT_DIR/opencode-prompt.md"

ROADMAP_FILE="$ROOT_DIR/ROADMAP.md"
PROJECT_DESC_FILE="$ROOT_DIR/project_description.md"
RULER_FILE="$ROOT_DIR/RULER.md"

mkdir -p "$OUT_DIR"

in_progress_line="$(grep -n "(IN_PROGRESS)" "$ROADMAP_FILE" || true)"
if [[ -z "$in_progress_line" ]]; then
  echo "No IN_PROGRESS step found in ROADMAP.md" >&2
  exit 1
fi

count_in_progress="$(printf "%s\n" "$in_progress_line" | wc -l | tr -d ' ')"
if [[ "$count_in_progress" != "1" ]]; then
  echo "Expected exactly one IN_PROGRESS step in ROADMAP.md, found: $count_in_progress" >&2
  exit 1
fi

active_step="$(printf "%s\n" "$in_progress_line" | head -n 1 | awk -F: '{print $2}' | sed 's/ (IN_PROGRESS)//')"

cat >"$OUT_FILE" <<EOF
# OpenCode Task Prompt

## Goal
Implement the ROADMAP current step in this repository.

## Current Step (from ROADMAP.md)
${active_step}

## Context Files (read first)
- project_description.md
- ROADMAP.md
- RULER.md

## Constraints
- Follow RULER.md strictly (coding style, API conventions, security/auth assumptions).
- Keep changes minimal and verifiable.
- Do not suppress type safety (no \`as any\`, no \`@ts-ignore\`).
- After changes, the quality gate must pass:
  - \`docker compose run --rm api npm run verify\`

## What to do
1) Read \`project_description.md\` and identify the exact scope implied by the current step.
2) Implement the smallest set of changes to complete the step.
3) Add/adjust tests so the behavior is verifiable.
4) Run the quality gate and fix any failures caused by your changes.

## Verification Commands (must pass)
\`docker compose run --rm api npm run verify\`

## Expected Evidence
- The verification command exits with code 0.
- If a runtime change is involved, \`curl -fsS http://localhost:3000/health\` returns 200 and JSON.
EOF

echo "$OUT_FILE"

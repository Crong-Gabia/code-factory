#!/usr/bin/env bash
set -euo pipefail

ROADMAP_FILE="${ROADMAP_FILE:-ROADMAP.md}"

if [[ ! -f "$ROADMAP_FILE" ]]; then
  echo "ROADMAP not found: $ROADMAP_FILE" >&2
  exit 1
fi

echo "Process trigger detected: reading $ROADMAP_FILE"
echo

in_progress="$(grep -n "(IN_PROGRESS)" "$ROADMAP_FILE" || true)"
done="$(grep -n "(DONE)" "$ROADMAP_FILE" || true)"
todo="$(grep -n "(TODO)" "$ROADMAP_FILE" || true)"

echo "Current state:"
echo "- IN_PROGRESS: ${in_progress:-<none>}"
echo "- DONE:        ${done:-<none>}"
echo "- TODO:        ${todo:-<none>}"
echo

if [[ -z "$in_progress" ]]; then
  echo "No IN_PROGRESS step found. Mark exactly one step as IN_PROGRESS to drive the process." >&2
  exit 1
fi

count_in_progress="$(printf "%s\n" "$in_progress" | wc -l | tr -d ' ')"
if [[ "$count_in_progress" != "1" ]]; then
  echo "Expected exactly one IN_PROGRESS step, found: $count_in_progress" >&2
  exit 1
fi

step_line="$(printf "%s\n" "$in_progress" | head -n 1)"
step_no="$(echo "$step_line" | awk -F: '{print $2}' | sed 's/ (IN_PROGRESS)//')"
echo "Active step: $step_no"
echo

echo "Suggested commands (demo):"
echo "- Verify code quality gate: npm run verify"
echo "- If DB is up (Docker): docker compose run --rm api npm run prisma:migrate"

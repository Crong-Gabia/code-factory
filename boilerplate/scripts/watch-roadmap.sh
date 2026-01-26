#!/usr/bin/env bash
set -euo pipefail

ROADMAP_FILE="${ROADMAP_FILE:-ROADMAP.md}"

if [[ ! -f "$ROADMAP_FILE" ]]; then
  echo "ROADMAP not found: $ROADMAP_FILE" >&2
  exit 1
fi

echo "Watching $ROADMAP_FILE for changes..."
echo "- On change: runs ./scripts/process.sh"

last="$(shasum "$ROADMAP_FILE" | awk '{print $1}')"
while true; do
  now="$(shasum "$ROADMAP_FILE" | awk '{print $1}')"
  if [[ "$now" != "$last" ]]; then
    last="$now"
    echo
    echo "ROADMAP changed at $(date)"
    bash ./scripts/process.sh
  fi
  sleep 1
done

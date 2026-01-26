#!/usr/bin/env bash
set -euo pipefail

# Sync a local oh-my-opencode config into the repo (gitignored) so Coder workspaces
# can apply it automatically.

SRC_PATH="${1:-}"

if [[ -z "$SRC_PATH" ]]; then
  echo "Usage: bash scripts/sync-oh-my-opencode-config.sh /path/to/oh-my-opencode.json" >&2
  echo "Example: bash scripts/sync-oh-my-opencode-config.sh \"$HOME/.config/opencode/oh-my-opencode.json\"" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="$ROOT_DIR/.coder/opencode"
DEST_PATH="$DEST_DIR/oh-my-opencode.json"

if [[ ! -f "$SRC_PATH" ]]; then
  echo "Config file not found: $SRC_PATH" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
cp "$SRC_PATH" "$DEST_PATH"

echo "Synced to: $DEST_PATH"
echo "Note: .coder/ is gitignored in this repo (secrets should not be committed)."

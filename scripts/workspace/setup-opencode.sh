#!/usr/bin/env bash
set -euo pipefail

# Runs inside the Coder workspace container.
# - Installs OpenCode + Oh My OpenCode (user-scoped)
# - Applies repo-provided config (gitignored) into ~/.config/opencode/

ROOT_DIR="/workspace"
USER_CONFIG_DIR="$HOME/.config/opencode"
LOCAL_OVERRIDE_CONFIG_PATH="$ROOT_DIR/.coder/opencode/oh-my-opencode.json"
CANONICAL_CONFIG_PATH="$ROOT_DIR/config/opencode/oh-my-opencode.json"

mkdir -p "$USER_CONFIG_DIR"

echo "[opencode] Ensuring OpenCode is installed"
bash "$ROOT_DIR/scripts/install-opencode.sh"

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

echo "[opencode] Ensuring oh-my-opencode is installed (user prefix)"
npm_prefix="${OPENCODE_NPM_PREFIX:-$HOME/.local}"
mkdir -p "$npm_prefix" "$npm_prefix/bin"
npm install -g --prefix "$npm_prefix" oh-my-opencode@latest

echo "[opencode] Installing oh-my-opencode integration"
"$npm_prefix/bin/oh-my-opencode" install || true

selected_config=""
if [[ -f "$LOCAL_OVERRIDE_CONFIG_PATH" ]]; then
  selected_config="$LOCAL_OVERRIDE_CONFIG_PATH"
elif [[ -f "$CANONICAL_CONFIG_PATH" ]]; then
  selected_config="$CANONICAL_CONFIG_PATH"
fi

if [[ -n "$selected_config" ]]; then
  echo "[opencode] Applying oh-my-opencode config: $selected_config"
  cp "$selected_config" "$USER_CONFIG_DIR/oh-my-opencode.json"
else
  echo "[opencode] No oh-my-opencode config found (skipping)"
  echo "[opencode] Looked for:"
  echo "[opencode] - $LOCAL_OVERRIDE_CONFIG_PATH"
  echo "[opencode] - $CANONICAL_CONFIG_PATH"
fi

echo "[opencode] Done"

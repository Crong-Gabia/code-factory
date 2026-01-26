#!/usr/bin/env bash
set -euo pipefail

# Runs inside the Coder workspace container.
# - Installs OpenCode + Oh My OpenCode (user-scoped)
# - Applies repo-provided config (gitignored) into ~/.config/opencode/

ROOT_DIR="/workspace"
USER_CONFIG_DIR="$HOME/.config/opencode"
REPO_CONFIG_PATH="$ROOT_DIR/.coder/opencode/oh-my-opencode.json"

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

if [[ -f "$REPO_CONFIG_PATH" ]]; then
  echo "[opencode] Applying repo config: $REPO_CONFIG_PATH"
  cp "$REPO_CONFIG_PATH" "$USER_CONFIG_DIR/oh-my-opencode.json"
else
  echo "[opencode] No repo config found at $REPO_CONFIG_PATH (skipping)"
fi

echo "[opencode] Done"

#!/usr/bin/env bash
set -euo pipefail

# Minimal bootstrap to run INSIDE the Lume VM.
# - No secrets
# - Non-admin install (no sudo) for unattended automation

log() { echo "[vm-bootstrap] $*"; }
warn() { echo "[vm-bootstrap][WARN] $*" >&2; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  warn "This script is intended for macOS VMs. Detected: $(uname -s)"
fi

NVM_VERSION="v0.39.7"
export NVM_DIR="$HOME/.nvm"

if ! command -v node >/dev/null 2>&1; then
  log "node not found. Installing nvm (${NVM_VERSION}) + Node LTS (no sudo)..."
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

  # shellcheck disable=SC1090
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  nvm install --lts
  nvm alias default 'lts/*'
fi

if ! command -v npm >/dev/null 2>&1; then
  warn "npm not found after node install; open a new shell and retry"
  exit 1
fi

if ! command -v opencode >/dev/null 2>&1; then
  log "Installing opencode + oh-my-opencode (npm global)..."
  npm install -g opencode@latest oh-my-opencode@latest
fi

log "Done."
log "- node: $(node -v)"
log "- opencode: $(opencode --version 2>/dev/null || true)"

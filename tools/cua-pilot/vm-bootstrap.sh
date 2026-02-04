#!/usr/bin/env bash
set -euo pipefail

# Minimal bootstrap to run INSIDE the Lume VM.
# - No secrets
# - Keep this lightweight for the 1-week pilot

log() { echo "[vm-bootstrap] $*"; }
warn() { echo "[vm-bootstrap][WARN] $*" >&2; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  warn "This script is intended for macOS VMs. Detected: $(uname -s)"
fi

if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found. Installing (non-interactive)..."
  export NONINTERACTIVE=1
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Homebrew shellenv (Apple Silicon default location)
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

log "Installing base tooling (git, node)..."
brew update
brew install git node

if ! command -v opencode >/dev/null 2>&1; then
  log "Installing opencode CLI (npm global)..."
  npm install -g opencode@latest
fi

log "Done."
log "- node: $(node -v)"
log "- opencode: $(opencode --version 2>/dev/null || true)"

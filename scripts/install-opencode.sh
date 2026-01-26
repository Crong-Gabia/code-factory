#!/usr/bin/env bash
set -euo pipefail

# Installs the OpenCode CLI inside a Linux environment (e.g. Coder workspace container).
# This is the "worker" that can execute coding tasks.

if command -v opencode >/dev/null 2>&1; then
  echo "opencode already installed: $(command -v opencode)"
  opencode --version || true
  exit 0
fi

if command -v npm >/dev/null 2>&1; then
  # Prefer npm install because some networks block install.opencode.ai DNS.
  # In containers, global installs to /usr/local often require root.
  echo "Installing OpenCode CLI via npm (preferred)..."
  npm_prefix="${OPENCODE_NPM_PREFIX:-$HOME/.local}"
  mkdir -p "$npm_prefix" "$npm_prefix/bin"

  # Install under a user-writable prefix.
  npm install -g --prefix "$npm_prefix" opencode-ai@latest

  # Ensure PATH guidance.
  if [[ ":$PATH:" != *":$npm_prefix/bin:"* ]]; then
    echo
    echo "Add to PATH (current shell):"
    echo "  export PATH=\"$npm_prefix/bin:\$PATH\""
    echo
    echo "Persist for future shells:"
    echo "  echo 'export PATH=\"$npm_prefix/bin:\$PATH\"' >> ~/.bashrc"
  fi
else
  if ! command -v curl >/dev/null 2>&1; then
    echo "Neither npm nor curl found. Install one of them first." >&2
    exit 1
  fi

  # Fallback to upstream install script.
  if getent hosts install.opencode.ai >/dev/null 2>&1; then
    echo "Installing OpenCode CLI via install script..."
    curl -fsSL https://install.opencode.ai | bash
  else
    echo "install.opencode.ai does not resolve (DNS). Install npm first or adjust DNS." >&2
    exit 1
  fi
fi

if command -v opencode >/dev/null 2>&1; then
  echo "Installed: $(command -v opencode)"
  opencode --version || true
  exit 0
fi

# Common install locations.
for d in "$HOME/.local/bin" "$HOME/.opencode/bin" "$HOME/bin"; do
  if [[ -x "$d/opencode" ]]; then
    echo "Found opencode at: $d/opencode"
    echo
    echo "Add to PATH (current shell):"
    echo "  export PATH=\"$d:\$PATH\""
    echo
    echo "Persist for future shells:"
    echo "  echo 'export PATH=\"$d:\$PATH\"' >> ~/.bashrc"
    exit 0
  fi
done

echo "Install finished but opencode not found on PATH." >&2
echo "Check install output above and ensure the install dir is in PATH." >&2
exit 1

#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# Ensure common user bin path is available for this process.
export PATH="$PATH:$HOME/.local/bin"

bash "./setup.sh" --yes

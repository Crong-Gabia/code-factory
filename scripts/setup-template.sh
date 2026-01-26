#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_DIR="${TEMPLATE_DIR:-coder-template}"
TEMPLATE_NAME="${TEMPLATE_NAME:-docker-dev-factory}"
REPO_PATH_DEFAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_PATH="${REPO_PATH:-$REPO_PATH_DEFAULT}"

if ! command -v coder >/dev/null 2>&1; then
  echo "coder CLI not found. Install with: curl -L https://coder.com/install.sh | sh" >&2
  exit 1
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Template directory not found: $TEMPLATE_DIR" >&2
  exit 1
fi

echo "Pushing Coder template '$TEMPLATE_NAME' from $TEMPLATE_DIR"
echo "- repo_path variable: $REPO_PATH"
echo

echo "If not logged in yet, run:"
echo "  coder login http://localhost:3001"
echo

# Basic connectivity check
if ! curl -fsS http://localhost:3001 >/dev/null 2>&1; then
  echo "Coder server does not seem reachable at http://localhost:3001" >&2
  echo "Start it first: bash scripts/start-coder.sh" >&2
  exit 1
fi

set +e
coder templates push "$TEMPLATE_NAME" \
  -d "$TEMPLATE_DIR" \
  --variable repo_path="$REPO_PATH" \
  --yes \
  --ignore-lockfile
rc=$?
set -e

if [[ $rc -ne 0 ]]; then
  echo >&2
  echo "Template push failed. Retry interactively:" >&2
  echo "  coder templates push $TEMPLATE_NAME -d $TEMPLATE_DIR --variable repo_path=\"$REPO_PATH\"" >&2
  exit $rc
fi

echo
echo "Done. Next: create a workspace from template '$TEMPLATE_NAME' in the UI."

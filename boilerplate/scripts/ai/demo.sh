#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "[1/4] Init plan docs (project_description.md -> ROADMAP/RULER/AGENTS/GEMINI)"
bash "$ROOT_DIR/scripts/ai/init-plan.sh"

echo
echo "[2/4] Run current ROADMAP step via opencode"
bash "$ROOT_DIR/scripts/ai/run-opencode.sh"

echo
echo "[3/4] Start Docker services"
docker compose up --build -d

echo
echo "[4/4] Verify"
curl -fsS http://localhost:3000/health
docker compose run --rm api npm run verify

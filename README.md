# code-factory

This repo contains:

- Local Coder quickstart (macOS + local Coder binary + Docker-based workspace template)
- A runnable local Docker boilerplate (`boilerplate/`) to validate inside a Coder workspace
- A project generator (`dev-factory/`) that can generate Express/Nest + MySQL templates into `dev-factory/output/`

## Local Coder quickstart

Follow: `docs/LOCAL_CODER_QUICKSTART.md`

Korean guide: `docs/LOCAL_CODER_QUICKSTART.ko.md`

If you got stuck on setup, the Korean guide includes a "삽질/장애 기록" section with fixes.

## Boilerplate (for workspace test)

```bash
cd boilerplate
docker compose up --build -d
curl -fsS http://localhost:3000/health
docker compose run --rm api npm run verify
```

## OpenCode local demo (project_description -> plan -> run)

Inside a workspace where `opencode` is installed + authenticated:

```bash
cd boilerplate

# 1) Write/adjust project_description.md
# 2) Generate plan docs (GEMINI/AGENTS/RULER/ROADMAP)
npm run ai:init-plan

# 3) Implement ROADMAP (IN_PROGRESS) step via opencode
npm run ai:run
```

## GitHub Actions demo (project_description -> PR -> run -> PR)

See: `docs/GITHUB_ACTIONS_AUTOMATION.md`

## Dev-factory generator

```bash
cd dev-factory
npm install
npm run build
npm run factory:init
```

Generated projects land in:

- `dev-factory/output/<project-name>`

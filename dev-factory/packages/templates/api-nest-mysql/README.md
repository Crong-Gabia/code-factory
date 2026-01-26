# **PROJECT_NAME**

Local Docker dev factory boilerplate (Nest + MySQL 8 + Prisma).

## Run (Docker)

```bash
docker compose up --build -d
curl -fsS http://localhost:3000/health
docker compose run --rm api npm test
docker compose run --rm api npm run verify
```

## Document-driven demo (ROADMAP triggers the process)

```bash
npm run process
```

Watch mode:

```bash
npm run process:watch
```

## DB migration

In Docker, migrations run automatically on container start.

Manual run:

```bash
docker compose run --rm api npm run prisma:migrate
```

## OpenCode local demo (plan -> run)

Prereq: `opencode` is installed + authenticated in the workspace.

```bash
# 1) Write/adjust project_description.md
# 2) Generate plan docs (GEMINI/AGENTS/RULER/ROADMAP)
npm run ai:init-plan

# 3) Implement ROADMAP (IN_PROGRESS) step via opencode
npm run ai:run

# 4) Or run the full flow (includes docker up + verify)
npm run ai:demo
```

# **PROJECT_NAME**

Local Docker dev factory boilerplate (Express + MySQL 8 + Prisma).

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

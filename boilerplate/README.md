# boilerplate

Local Docker dev factory boilerplate (Express + MySQL 8 + Prisma).

## Run (Docker)

```bash
docker compose up --build -d
curl -fsS http://localhost:3000/health
docker compose run --rm api npm test
docker compose run --rm api npm run verify
```

## Document-driven demo (ROADMAP triggers the process)

Change `ROADMAP.md` status markers and trigger the process runner:

```bash
npm run process
```

To auto-run on changes:

```bash
npm run process:watch
```

## DB migration

In Docker, migrations run automatically on container start:

```bash
docker compose logs -f api
```

Manual run:

```bash
docker compose run --rm api npm run prisma:migrate
```

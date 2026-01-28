# Project Rules (RULER)

This file defines the **rules and guardrails** for evolving this repo.

## Purpose & Scope

- Purpose: Demo an **Express + MySQL + Prisma** API boilerplate that is maintained by non-interactive agents driven by documentation changes.
- In scope:
  - `GET /health` endpoint.
  - `POST /users`, `GET /users` endpoints.
  - User email must be **unique**.
  - DB schema and migrations managed by **Prisma** against **MySQL**.
- Out of scope (for now):
  - Authentication / authorization flows.
  - External integrations (mail, payments, third-party APIs).

## Hard Technical Rules

1. **Verification is mandatory**
   - After meaningful changes (code, schema, or tests), run:
     - `docker compose run --rm api npm run verify`
   - A change is **not complete** if this command fails.

2. **Database & schema**
   - Use Prisma as the single source of truth for the MySQL schema.
   - Migrations must be reproducible and checked into the repo.
   - Email uniqueness must be enforced at the DB/Prisma layer (unique index) and covered by tests.

3. **API design**
   - `GET /health` should return HTTP 200 with a small JSON body indicating service status.
   - `POST /users` should create a user and return HTTP 201 with user data (or a validation/conflict error if invalid/duplicate).
   - `GET /users` should list users with predictable ordering (e.g., by creation time).

4. **Testing philosophy**
   - Favor **realistic, end-to-end or integration-style tests** that exercise Express routes + Prisma + MySQL together.
   - Never delete tests solely to fix a failing verify run.
   - When a bug is found, add or extend a test before fixing the code.

## Non-functional Requirements (NFRs)

These are intentionally lightweight but should guide future roadmap items.

### Availability

- Service should be simple to run locally via Docker Compose.
- Startup should fail fast if the DB is unreachable or migrations are missing.

### Performance

- Endpoints are low-volume but should avoid unnecessary N+1 queries.
- Keep latency reasonable for typical CRUD operations with Prisma and MySQL.

### Security

- Do not log sensitive data such as raw passwords (if introduced later).
- Validate and sanitize user input for `/users` endpoints.

### Observability

- Prefer structured logging (e.g., JSON logs) over ad-hoc console prints.
- Log at least: request method, path, status code, and latency for each HTTP request.

## Process Rules for Agents

- Follow `ROADMAP.md` ordering; do not jump ahead without updating the roadmap first.
- Before introducing new concepts (e.g., auth, queues), update this file to extend the rules.
- Keep changes small and tied to a single roadmap step.
- Prefer improving tests and docs alongside behavior changes.

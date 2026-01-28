# Draft: ROADMAP Step 3 - Minimal API Implementation

## Requirements (confirmed)

- Implement minimal API endpoints as defined in `project_description.md`:
  - `GET /health` (200 + JSON)
  - `POST /users` (201 + JSON)
  - `GET /users` (200 + JSON, email unique)
- Respect `RULER.md` conventions:
  - Small, testable functions; one responsibility per file.
  - No type safety suppression.
  - JSON fields use `snake_case`.
  - DTOs only at I/O boundaries.
  - Standard error envelope `{ "error": { "code", "message", "trace_id" } }`.
  - Propagate `x-request-id`; minimal validation at I/O boundaries.
- Scope is limited to the endpoints above plus required Prisma schema/migrations and tests so that `docker compose run --rm api npm run verify` passes.

## Technical Decisions

- Stack: Express + MySQL + Prisma as already configured in the boilerplate.
- Prisma `User` model already exists in `prisma/schema.prisma` with unique `email`.
- Existing routers: `healthRouter` with `GET /health`, `meRouter` with `GET /me`.
- Error handling middleware already returns standard error envelope with `trace_id`.

## Research Findings

- `GET /health` is already implemented using `checkDbHealth` and returns `{ status: "up", db }`.
- Prisma client is provided via `getPrisma()` helper with lazy initialization.
- `userContext` middleware reads user info from ingress headers and stores it on `req.user` (per RULER description).
- Test harness uses Jest + Supertest via `scripts/run-tests.cjs` and `npm run verify` chains `ruler:check`, `lint`, and `test`.

## Open Questions

- Response DTO shapes for `POST /users` and `GET /users` (field names, whether to include `created_at`, etc.).
- Exact validation rules and error codes for invalid input or duplicate emails beyond Prisma unique constraint error.
- Whether `GET /users` should support pagination or always return full list (minimal scope suggests full list).

## Scope Boundaries

- INCLUDE: Minimal implementations for `POST /users` and `GET /users`, necessary Prisma usage, routing, and tests to satisfy `npm run verify`.
- EXCLUDE: AuthN/AuthZ, advanced validation, pagination, sorting, external integrations, or endpoints beyond the specified minimal API.

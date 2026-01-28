# Roadmap

This roadmap defines **concrete, verifiable steps** to evolve the Express + MySQL + Prisma API boilerplate. Exactly one step is marked as `(IN_PROGRESS)`.

## Steps

1. (IN_PROGRESS) Establish AI-facing docs and rules
   - **Goal**: Create and maintain `GEMINI.md`, `AGENTS.md`, `RULER.md`, and this `ROADMAP.md` so agents can work safely on the repo.
   - **Includes**:
     - Document project purpose, scope, and constraints.
     - Define agent roles and collaboration patterns.
     - Define project rules and non-functional requirements.
   - **How to verify**:
     - Manually review the four docs for consistency with `project_description.md`.
     - Run: `docker compose run --rm api npm run verify` to ensure doc changes did not break the build/tests.

2. Implement minimal API and schema
   - **Goal**: Ensure `GET /health`, `POST /users`, and `GET /users` are implemented against MySQL via Prisma with a unique email constraint.
   - **Includes**:
     - Prisma schema and migration(s) for a `User` model with unique email.
     - Express routes (or equivalent) for the three endpoints.
     - Basic error handling for duplicate emails and invalid input.
   - **How to verify**:
     - Run: `docker compose run --rm api npm run verify`.
     - Manually call the endpoints (e.g., via curl or HTTP client) to confirm expected behavior.

3. Add automated tests for user flows
   - **Goal**: Cover core behaviors for `/users` endpoints with automated tests.
   - **Includes**:
     - Tests for creating users, listing users, and handling duplicate emails.
     - Tests that exercise the stack end-to-end (HTTP -> Prisma -> MySQL).
   - **How to verify**:
     - Run: `docker compose run --rm api npm run verify` and confirm all tests pass.

4. Improve observability and basic operational readiness
   - **Goal**: Make the service easier to operate and debug.
   - **Includes**:
     - Structured logging for HTTP requests and key events.
     - Clear error responses for validation and conflict cases.
   - **How to verify**:
     - Run: `docker compose run --rm api npm run verify`.
     - Exercise endpoints and confirm logs contain method, path, status code, and latency.

5. Harden automation for docs-triggered agent flow
   - **Goal**: Ensure that documentation changes reliably trigger the non-interactive agent and result in a PR.
   - **Includes**:
     - Any required CI/automation configuration so that doc changes run the agent.
     - Documentation of the flow in `GEMINI.md` / `AGENTS.md`.
   - **How to verify**:
     - Make a small documentation-only change and push it.
     - Confirm that the automation runs `docker compose run --rm api npm run verify` and opens a PR with the agent's changes.

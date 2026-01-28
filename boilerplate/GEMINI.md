# GEMINI Guide

## What this repo is

- Demo API boilerplate using **Express + MySQL + Prisma**.
- Goal: validate a **docs-triggered, non-interactive OpenCode agent** that updates the project and opens PRs.
- Minimal product scope (from `project_description.md`):
  - `GET /health`
  - `POST /users`, `GET /users` with **unique email** constraint
  - DB via **Prisma** schema targeting **MySQL**
  - Verification command must always pass:
    - `docker compose run --rm api npm run verify`

You are an AI engineer working in this repo. Your primary job is to evolve the boilerplate while keeping `npm run verify` green inside docker.

## Hard constraints for this phase

- This initialization phase is **docs-only**:
  - You may create/update: `GEMINI.md`, `AGENTS.md`, `RULER.md`, `ROADMAP.md`.
  - **Do NOT change application code** yet (Express handlers, Prisma schema, etc.).
- All work must respect the current project description and stay realistic for an Express/MySQL/Prisma boilerplate.
- The canonical verification is:
  - `docker compose run --rm api npm run verify`

## How to think about the system

1. **Service purpose**
   - Provide a minimal, but realistic, user API over MySQL using Prisma.
   - Act as a sandbox for OpenCode-style agents that react to doc changes and open PRs.

2. **Architecture (intended)**
   - HTTP layer: Express (or Nest-style patterns) exposing `/health` and `/users` endpoints.
   - Data layer: Prisma client + schema mapped to a MySQL database.
   - Infra: Docker Compose orchestrating the API container and MySQL.

3. **In-scope vs out-of-scope**
   - In scope:
     - Health check endpoint.
     - Basic user lifecycle: create and list users.
     - Enforcing **unique user email** at DB / Prisma level and in tests.
   - Out of scope (do **not** add unless roadmap explicitly says so):
     - AuthN/AuthZ.
     - External integrations (mail, payments, third-party APIs).

## How you should work

1. **Read the docs first**
   - `project_description.md` — single source of truth for purpose & scope.
   - `RULER.md` — rules, constraints, non-functional expectations.
   - `AGENTS.md` — how different agents collaborate here.
   - `ROADMAP.md` — ordered, testable steps for evolving the boilerplate.

2. **Follow the roadmap**
   - Pick the step marked `(IN_PROGRESS)` in `ROADMAP.md` as the current focus.
   - Do not start future steps early unless the roadmap is explicitly updated.

3. **Guard the verification command**
   - After any change that might affect runtime behavior or tests, run:
     - `docker compose run --rm api npm run verify`
   - If it fails, **fix the root cause**; do not weaken tests.

4. **Respect boundaries**
   - Stay within the in-scope feature set.
   - Do not introduce unrelated technologies or services.
   - When in doubt, update `RULER.md` and `ROADMAP.md` first, then implement.

## What good contributions look like

- Small, focused changes tied to a specific roadmap step.
- Clear, testable behavior that is covered by `npm run verify`.
- Updates to docs when behavior or constraints change.
- No type-unsafe hacks, no suppressed errors, no deleted tests to "make it pass".

Use this file as your quick mental model for the project before you dive into code.

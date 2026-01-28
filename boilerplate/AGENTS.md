# Agents Guide

This repo is designed to be driven by **agents** (LLMs) that react to documentation changes and open PRs. This file defines how those agents should collaborate.

## Roles

### Planner (Prometheus / Plan agent)

- **Responsibility**: Turn high-level goals and doc changes into a concrete work plan.
- **Typical questions**:
  - Which files need to change?
  - What is the smallest verifiable step?
  - How do we keep `docker compose run --rm api npm run verify` passing?
- **Output**: A set of small, ordered tasks that an implementation agent can execute.

### Explorer (codebase search)

- **Responsibility**: Understand the existing code and docs.
- **Tools**: workspace search, AST-grep, LSP navigation.
- **Usage**:
  - Locate existing Express routes, Prisma models, migrations, and tests.
  - Discover existing patterns for error handling, validation, and logging.

### Librarian (external references)

- **Responsibility**: Pull in **external knowledge** when needed.
- **Scope**:
  - Official docs for Express, Prisma, MySQL.
  - Examples from reputable open source projects.
- **Usage**:
  - When designing new modules or behavior not yet present in the repo.

### Implementer (Sisyphus-Junior / build agent)

- **Responsibility**: Apply code and docs changes following the plan.
- **Rules**:
  - Follow `RULER.md` for constraints.
  - Follow `ROADMAP.md` for ordering and scope.
  - Keep the repo in a buildable, testable state.
- **Verification**:
  - Run `docker compose run --rm api npm run verify` after any non-trivial change.

### Oracle (architecture/debugging advisor)

- **Responsibility**: High-level reasoning for tricky bugs or design decisions.
- **Usage**:
  - When migrations are risky.
  - When performance, security, or data integrity trade-offs are involved.

## Collaboration Workflow

1. **Trigger**: A change to docs (typically `ROADMAP.md` or `RULER.md`) signals new work.
2. **Planner**: Interprets the change and produces a concrete task list.
3. **Explorer**: Analyzes the current implementation to understand what already exists.
4. **Librarian**: Fetches best practices or API usage patterns if needed.
5. **Implementer**: Applies the minimal set of changes to satisfy the task.
6. **Oracle** (optional): Reviews complex plans or failed attempts before retrying.
7. **Verifier**: Implementation agent runs `docker compose run --rm api npm run verify` and ensures success.

## Safety Rules for Agents

- Prefer **small, incremental PRs** over large refactors.
- Never delete or weaken tests to fix a failing `npm run verify` run.
- Do not introduce new external services beyond MySQL without updating `RULER.md` and `ROADMAP.md` first.
- Preserve existing behavior unless the roadmap explicitly calls for a change.

## Docs-driven flow

During this initialization phase:

- Planner and Implementer focus on **documentation only**:
  - `GEMINI.md`
  - `AGENTS.md`
  - `RULER.md`
  - `ROADMAP.md`
- Future phases may enable code changes, but they must always be:
  - Motivated by a roadmap step.
  - Guarded by `docker compose run --rm api npm run verify`.

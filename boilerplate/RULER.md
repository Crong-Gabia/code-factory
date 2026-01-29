# Ruler (Project Rules)

This project uses https://github.com/intellectronica/ruler.

## Coding Style

- Prefer small, testable functions.
- Keep files focused (one primary responsibility per file).
- Avoid hidden side effects; pass dependencies explicitly.
- No type-safety suppression (no `as any`, no `@ts-ignore`).

## JSON / DTO

- JSON field naming: prefer `snake_case` across the project.
- DTOs are for I/O boundaries only (HTTP request/response, DB row). Keep them separate from domain models.

## API Conventions

- URL: kebab-case, versioning is optional (`/v1/...` if introduced).
- Avoid verb-heavy paths (prefer resources like `/documents`, `/spaces/{id}`).
- DTO naming (example): `CreateXRequest`, `XResponse`.
- Success response: JSON object.

### Error Model (recommended minimum)

All error responses should follow a standard structure:

```json
{ "error": { "code": "STRING", "message": "STRING", "trace_id": "STRING" } }
```

## Logging / Observability

- Error logs MUST include: `trace_id`, `message`, `error_name`.
- Propagate a request identifier (`x-request-id`) end-to-end.

## Security Guidelines

- JWT is validated at Ingress, not in this app.
- User identity is trusted only behind Ingress/internal network.
- Never log credentials, tokens, or PII.
- Do not commit secrets (keys/tokens/passwords).
- Minimal input validation at I/O boundaries.

## Git Workflow

- Default/base branch: `main`.
- All work must be done on a new branch with one of these prefixes:
  - `feature/` for features/changes
  - `fix/` for bug fixes
- Open a PR targeting `main`.
- Avoid direct pushes to `main` (enforce via GitHub branch protection / rulesets).

## Pull Request (PR) Rules (Required)

### Language

- All PR titles and PR bodies MUST be written in Korean.
- If the change introduces or references user-facing behavior, keep the wording understandable to non-developers.

### PR Body Template

- All PRs MUST follow the repository PR template (`.github/pull_request_template.md`).
- At minimum, the PR body must include:
  - 목적
  - 변경사항
  - 검증
  - Risks & Edge Cases
  - Decision Log
  - Known Issues
  - Rollback Plan

### Quality bar

- If there are known risks or edge cases, they MUST be explicitly listed.
- If there are meaningful tradeoffs, they MUST be recorded in Decision Log (alternatives considered + why chosen).

## Auth (Ingress JWT assumption)

- App does not verify JWT.
- `src/middlewares/userContext.ts` reads headers:
  - `x-user-id`
  - `x-user-email`
  - `x-user-roles`
- The middleware stores the user on `req.user`.

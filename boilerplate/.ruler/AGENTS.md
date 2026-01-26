# Dev Factory Boilerplate Rules

You are working in a local Docker dev boilerplate.

- Keep changes minimal and verifiable.
- Prefer explicit, typed APIs.
- Preserve stable developer experience: `docker compose up --build -d` and `npm run verify` must pass.

API / Process demo:

- JSON response fields should prefer `snake_case`.
- Error model should include `code`, `message`, `trace_id`.
- `ROADMAP.md` changes are considered a process trigger for the demo; use `npm run process` or `npm run process:watch`.

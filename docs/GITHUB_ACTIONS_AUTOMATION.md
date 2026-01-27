# GitHub Actions automation (MVP)

This repo includes two workflows to demonstrate:

- `project_description.md` -> plan docs PR
- `ROADMAP.md` (IN_PROGRESS) -> implementation PR

## Workflows

- `.github/workflows/opencode-init-plan.yml`
  - Trigger: change to `boilerplate/project_description.md` on `develop`
  - Runs: `cd boilerplate && npm run ai:init-plan`
  - Output: PR that updates/creates `GEMINI.md`, `AGENTS.md`, `RULER.md`, `ROADMAP.md`

- `.github/workflows/opencode-run-roadmap.yml`
  - Trigger: change to `boilerplate/ROADMAP.md` (or `boilerplate/RULER.md`) on `develop`
  - Runs: `cd boilerplate && npm run ai:run`, then `docker compose up` and `npm run verify`
  - Output: PR that implements the current `(IN_PROGRESS)` step

## Branch policy

This repo expects a Git workflow:

- Base branch: `develop`
- Work branches: `feature/*` or `fix/*`
- PRs must target `develop`

Automation enforces this via:

- `.github/workflows/branch-policy.yml`

## Required repo variables

Set repository variables (Settings -> Secrets and variables -> Actions -> Variables):

- `OPENCODE_MODEL`
  - Example: `openai/gpt-4.1` or your preferred provider/model
- `OPENCODE_AGENT` (optional)
  - Example: `sisyphus`

## Required secrets

Depending on the provider used by `OPENCODE_MODEL`, set one of these secrets:

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`
- `OPENROUTER_API_KEY`

If you use a different provider, add its key as a secret and expose it in the workflow `env`.

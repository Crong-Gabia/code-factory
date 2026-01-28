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

- `OPENCODE_MODEL` (optional)
  - If set, it is passed to `opencode run --model ...`.
  - Recommendation: keep it consistent with `config/opencode/oh-my-opencode.json`.
- `OPENCODE_AGENT`
  - Example: `sisyphus`
  - The agent->model mapping is defined in `config/opencode/oh-my-opencode.json` and applied by the workflows.

## Required secrets

Depending on the models used by `config/opencode/oh-my-opencode.json`, set the required provider API key(s) as GitHub Secrets:

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`
- `OPENROUTER_API_KEY`

If you use a different provider, add its key as a secret and expose it in the workflow `env`.

## Keeping local/Coder/GitHub Actions consistent

- Canonical config (committed): `config/opencode/oh-my-opencode.json`
- Local override (gitignored): `.coder/opencode/oh-my-opencode.json`

Coder workspace applies:

- `.coder/opencode/oh-my-opencode.json` if present
- otherwise `config/opencode/oh-my-opencode.json`

GitHub Actions always applies:

- `config/opencode/oh-my-opencode.json`

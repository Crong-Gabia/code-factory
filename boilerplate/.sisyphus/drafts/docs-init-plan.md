# Draft: Docs Init Plan (GEMINI/AGENTS/RULER/ROADMAP)

## Requirements (confirmed)

- Generate four documentation files: `GEMINI.md`, `AGENTS.md`, `RULER.md`, `ROADMAP.md` for this repo.
- Follow constraints from `.ai/opencode-init-plan.md`:
  - `ROADMAP.md` must have at least 5 concrete steps.
  - Exactly one step marked `(IN_PROGRESS)`.
  - Steps must be verifiable (mention how to verify, e.g. npm scripts/commands).
  - Scope realistic for Express/Nest + MySQL + Prisma backend.
  - Init phase must not change application code; only these docs.
- Align all docs with `project_description.md` describing a Confluence/Notion-like collaborative Markdown knowledge/docs backend with spaces/pages, links, and per-scope visibility.

## Technical Decisions

- Treat the stack as Node/TypeScript backend with Express + MySQL 8 + Prisma (as per README).
- Documentation work only; no source code or config changes in this phase.
- ROADMAP verification commands can reference existing scripts from README (`docker compose` flows, `npm test`, `npm run verify`, `npm run process`, `npm run ai:*`), and additional scripts must be clearly marked as "to be wired up".

## Research Findings

- `.ai/opencode-init-plan.md` defines that the init task is exactly to create GEMINI/AGENTS/RULER/ROADMAP, with constraints on ROADMAP and a strict "no app code changes" rule.
- `project_description.md` defines this project as a backend API for a collaborative Markdown knowledge/docs system, with:
  - Markdown-based documents.
  - Document-level URLs and cross-document links.
  - Visibility controls at space, page tree, and page levels.
- `README.md` shows this boilerplate is Express + MySQL 8 + Prisma, with Docker-based workflows and npm scripts for tests, verification, process runner, and AI demo.

## Open Questions

- Should documentation (GEMINI/AGENTS/RULER/ROADMAP) be written primarily in English, Korean, or a mix (project_description currently mixes both)?
- Any existing conventions or examples for GEMINI/AGENTS/RULER/ROADMAP in other repos that we should mirror (naming sections, tone, etc.)?
- Preferred level of implementation detail vs. high-level guidance in RULER.md (e.g., concrete Express route patterns vs. general architectural constraints)?
- For ROADMAP.md, should the initial 5+ steps focus strictly on docs and process automation for this init phase, or also outline future API feature work at a high level (still without implementing app code)?

## Scope Boundaries

- INCLUDE:
  - Planning tasks to create complete, non-placeholder content for GEMINI.md, AGENTS.md, RULER.md, ROADMAP.md.
  - Alignment of doc content with project purpose/scope from `project_description.md` and stack/commands from `README.md`.
  - ROADMAP steps that are verifiable via existing commands or clearly marked "to be wired up".
- EXCLUDE:
  - Any modification of application source code, configuration, or database schema.
  - Implementation of new npm scripts or tooling (can only be referenced as future TODOs).
  - Execution of Docker or npm commands (plan only).

# Codex Skill Deployment

This repository is the source of truth for Codex skills.

## Split

Global candidates live in:

- [global-candidates.txt](/Users/jiajunchen/Development/awesome-claude-skills/codex/manifests/global-candidates.txt)

Project-only skills live in:

- [project-only.txt](/Users/jiajunchen/Development/awesome-claude-skills/codex/manifests/project-only.txt)

## Rules

- Keep reusable language, framework, and role skills as global candidates.
- Keep project-specific wrappers, local workflows, and business-domain rules project-local.
- Do not hand-edit copies in both places.
- Publish from this repo into the global skill directory when a skill is stable enough to reuse.

## Publish

Use the sync script:

`./scripts/publish-codex-skills.sh --dry-run`

Examples:

- Publish all global candidates:
  `./scripts/publish-codex-skills.sh`
- Publish one skill:
  `./scripts/publish-codex-skills.sh --skills react-frontend`
- Publish to a custom Codex home:
  `./scripts/publish-codex-skills.sh --codex-home /path/to/.codex`

Default destination:

- `${CODEX_HOME}/skills` when `CODEX_HOME` is set
- `~/.codex/skills` otherwise

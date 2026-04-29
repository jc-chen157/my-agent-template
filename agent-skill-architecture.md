# Agent and Skill Architecture

This repository now separates role from ecosystem.

## Why

Per-language engineer prompts duplicate too much:

- implementation mindset
- debugging mindset
- architecture reasoning
- observability expectations
- testing expectations

Those are role concerns, not language concerns.

Language and framework specifics belong in reusable skills.

## Claude Starter Layout

- `claude-starter/CLAUDE.md`
- `claude-starter/agents/backend-engineer.md`
- `claude-starter/agents/frontend-engineer.md`
- `claude-starter/agents/code-review-engineer.md`
- `claude-starter/skills/*.md`

Recommended pairing examples:

- Java service work: `backend-engineer` + `java-backend`
- Python API work: `backend-engineer` + `python-backend`
- Go service work: `backend-engineer` + `golang-backend`
- Rust service work: `backend-engineer` + `rust-server`
- React app work: `frontend-engineer` + `react-frontend`
- Node or Next.js backend work: `backend-engineer` + `node-nextjs-backend`
- Any review task: `code-review-engineer` + matching stack skill
- Test and verification review: `reviewer-test-quality`

## Codex Layout

- `codex/skills/backend-engineer-core/SKILL.md`
- `codex/skills/frontend-engineer-core/SKILL.md`
- `codex/skills/code-review-engineer-core/SKILL.md`
- `codex/skills/*/SKILL.md`

Recommended pairing examples:

- Backend implementation: `backend-engineer-core` + matching stack skill
- Frontend implementation: `frontend-engineer-core` + `react-frontend`
- Code review: `code-review-engineer-core` + matching stack skill
- Specialized test review: `reviewer-test-quality`

Planning workflow:

- Use `claude-starter/agents/master-planner.md` when the user wants planning before implementation.
- Keep planning workflow semantics in `claude-starter/planning/protocol.md`.
- Use `claude-starter/skills/planning-*.md` as stage transforms, not as peer planning agents.
- Hand work to execution agents only after the task packet is approved for execution.

Codex planning workflow:

- Use `codex/skills/mini-planner-core/SKILL.md` when Codex should plan before implementation.
- The Codex planner follows planning-protocol-v2 and is self-contained inside `codex/skills/mini-planner-core/`.
- Copying `codex/` to a new repository is enough to bring the Codex planning workflow with it.

Testing overlays:

- Writing backend tests: role/core + stack skill + matching `*-testing`
- Reviewing test quality: `reviewer-test-quality` + matching `*-testing`
- Shared fixture/setup work: covered by the matching `*-testing` skill

## Memory Rule

If an agent uses memory, it should be project-scoped rather than global. Shared global skills should stay reusable and avoid embedding repo-specific memory assumptions.

## Migration From Old Files

The old flat per-language prompt files are still available as references, but they should no longer be the primary structure.

The preferred model is:

1. Choose the role.
2. Load the stack skill.
3. Keep shared standards in one place.

For planning-first work:

1. Use the master planner.
2. Follow the protocol.
3. Use planning skills for stage transforms.
4. Execute only after approval.

This reduces duplication and makes updates cheaper.

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

## Claude Layout

- `claude/agents/backend-engineer.md`
- `claude/agents/frontend-engineer.md`
- `claude/agents/code-review-engineer.md`
- `claude/skills/*.md`

Recommended pairing examples:

- Java service work: `backend-engineer` + `java-backend`
- Python API work: `backend-engineer` + `python-backend`
- Go service work: `backend-engineer` + `golang-backend`
- Rust service work: `backend-engineer` + `rust-server`
- React app work: `frontend-engineer` + `react-frontend`
- Node or Next.js backend work: `backend-engineer` + `node-nextjs-backend`
- Any review task: `code-review-engineer` + matching stack skill
- Maintainability/design review: `reviewer-best-practice`
- Correctness/security review: `reviewer-logic-security`
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
- Specialized maintainability review: `reviewer-best-practice`
- Specialized correctness/security review: `reviewer-logic-security`
- Specialized test review: `reviewer-test-quality`

## Memory Rule

If an agent uses memory, it should be project-scoped rather than global. Shared global skills should stay reusable and avoid embedding repo-specific memory assumptions.

## Migration From Old Files

The old flat per-language prompt files are still available as references, but they should no longer be the primary structure.

The preferred model is:

1. Choose the role.
2. Load the stack skill.
3. Keep shared standards in one place.

This reduces duplication and makes updates cheaper.

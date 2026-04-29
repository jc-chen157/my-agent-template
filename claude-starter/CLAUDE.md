# Workflow Orchestration

This starter pack is intended to be installed as `.claude/` in the target repository.
All internal paths below assume that installed location.

## 1. Plan Mode Default

- Enter plan mode for any non-trivial task with 3 or more meaningful steps, cross-file changes, or architectural decisions.
- If the user asks for planning or uses the `planning:` prefix, use `.claude/agents/master-planner.md`.
- `.claude/planning/protocol.md` is the source of truth for the planning workflow. Plan templates live under `.claude/planning/templates/`.
- Use `.claude/agents/master-planner.md` for the entire planning engagement. Do not switch planners midstream.
- During planning, do not implement code before the relevant plan(s) are approved.
- Pick the smallest set of plan types that fits the work — feature plan, architecture plan, implementation plan, or a combination. Not every task needs all three.
- Skip plan types that do not apply. Delete sections inside a plan that do not apply. Do not write `N/A` or invent details to fill a template.
- Plan lifecycle is `working` → `approved`. Only the user promotes a plan to `approved`.
- Require user approval on each plan before doing the work it describes.
- When a plan is review-ready, print it inline so the user can review without opening another app.
- For every new planning engagement, create `.agents/plans/<short-slug>/` and add only the plan files that apply:
  - `feature-plan.md`
  - `architecture-plan.md`
  - `implementation-plan.md`
- If something goes sideways, stop and re-plan immediately instead of pushing through drift.
- Use plan mode for verification steps, not just building.

## 2. Subagent Strategy

- Use subagents liberally to keep the main context window clean.
- Offload research, exploration, and parallel analysis to subagents.
- For complex problems, use subagents to add focused parallel compute.
- Give one task per subagent for focused execution.
- Leverage skills whenever possible.
- In planning mode, keep one master planner. Do not introduce peer planners.
- **For implementation, use the `backed-engineer` or `front-engineer` depending on the implementation tasks**
- **Code review uses the project's three reviewers, not generic agents.**
  When `/simplify`, `/review`, or any explicit code review is requested,
  launch all three in parallel:
  - `reviewer-logic-security` — bugs, security, concurrency, resource leaks
  - `reviewer-best-practice` — maintainability, naming, abstraction, idioms
  - `reviewer-test-quality` — test scenarios, assertions, mocking, flake risks
    Do not substitute the harness defaults (`code-reviewer`,
    `architect-reviewer`) — those don't carry the team's review conventions
    defined in `.claude/agents/reviewer-*.md`. If the harness reports a
    reviewer name as unknown, fall back to `general-purpose` with the
    reviewer's `.md` content embedded as the system prompt rather than
    silently using a generic reviewer.

## 3. Self-Improvement Loop

- After any correction from the user, append the pattern to `.agents/lessons/` (one lesson per file, named by topic).
- Write rules for yourself that prevent the same mistake.
- Ruthlessly iterate on these lessons until the mistake rate drops.
- Review `.agents/lessons/` at session start when relevant entries exist.
- Persistent cross-session context (project facts, user preferences, references) belongs in `.agents/memory/`, not in lessons.

## 4. Verification Before Done

- Never mark a task complete without proving it works.
- Diff behavior between the main branch and your changes when relevant.
- Ask yourself whether a staff engineer would approve the result.
- Run tests, check logs, and demonstrate correctness.
- For behavior-changing work, prefer test-first validation and verify that the implementation satisfies the validation criteria in the implementation plan.

## 5. Demand Elegance (Balanced)

- For non-trivial changes, pause and ask whether there is a more elegant way.
- If a fix feels hacky, re-evaluate with everything you have learned and choose the cleaner solution.
- Skip this for simple, obvious fixes and avoid over-engineering.
- Challenge your own work before presenting it.

## 6. Autonomous Bug Fixing

- When given a bug report, fix it without requiring hand-holding.
- Use logs, errors, and failing tests to find the root cause, then resolve it.
- Minimize unnecessary context switching for the user.
- Fix failing CI tests without waiting for step-by-step instructions.

# Task Management

1. **Plan First**: Write plans under `.agents/plans/<short-slug>/` using the templates in `.claude/planning/templates/`.
2. **Verify Plan**: Check in before starting implementation when the task is non-trivial.
3. **Track Progress**: Mark items complete as you go.
4. **Explain Changes**: Give a high-level summary at each meaningful step.
5. **Document Results**: Update the relevant plan file under `.agents/plans/<short-slug>/` as work progresses; do not create parallel review docs.
6. **Capture Lessons**: After corrections, add a topic-named file under `.agents/lessons/`.
7. **Persist Context**: Store durable cross-session facts (project context, user preferences, references) under `.agents/memory/`.

# Core Principles

- **Simplicity First**: Make every change as simple as possible. Minimize blast radius.
- **No Laziness**: Find root causes. Do not ship temporary fixes as final solutions.
- **Minimal Impact**: Touch only what is necessary and avoid introducing new bugs.

# Claude Planning Notes

- `.claude/CLAUDE.md` is the source of truth for Claude configuration in the target repository.
- `.claude/planning/protocol.md` is the source of truth for the planning workflow itself.
- `.claude/planning/templates/` holds the plan-type templates: `feature-plan.md`, `architecture-plan.md`, `implementation-plan.md`.
- `.claude/agents/master-planner.md` is the only planning orchestrator across the full planning engagement.
- post-implementation validation belongs to review and test-quality agents, not the planner.

# Project Storage Layout

Artifacts are split between two top-level directories:

- `.agents/` — **agent-tool-agnostic** content. Any agent (Claude Code, Cursor, Codex, etc.) reads and writes here.
  - `.agents/plans/` — planning artifacts. Top-level PRDs (`PRD.md`, `PRD-PHASE-1.md`) plus `<short-slug>/` subdirectories for new planning engagements (feature, architecture, implementation plans).
  - `.agents/lessons/` — corrections-driven rules, one file per topic, reviewed at session start
  - `.agents/memory/` — durable cross-session context (project facts, user preferences, external references)
- `.claude/` — **Claude-specific configuration**.
  - `.claude/planning/` — protocol and plan templates (read-only configuration)
  - `.claude/agents/` — agent definitions (read-only configuration)
  - `.claude/skills/` — stack-specific skill files (read-only configuration)

Do not write planning artifacts, lessons, or memory anywhere else. Do not invent additional top-level directories without updating this section.

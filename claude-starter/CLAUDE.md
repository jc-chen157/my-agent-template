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
- For every new planning engagement, create `plans/<short-slug>/` and add only the plan files that apply:
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

## 3. Self-Improvement Loop

- After any correction from the user, update `tasks/lessons.md` with the pattern.
- Write rules for yourself that prevent the same mistake.
- Ruthlessly iterate on these lessons until the mistake rate drops.
- Review lessons at session start when the project has a relevant `tasks/lessons.md`.

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

1. **Plan First**: Write the plan to `tasks/todo.md` with checkable items when the project uses that workflow.
2. **Verify Plan**: Check in before starting implementation when the task is non-trivial.
3. **Track Progress**: Mark items complete as you go.
4. **Explain Changes**: Give a high-level summary at each meaningful step.
5. **Document Results**: Add a review section to `tasks/todo.md` when that file exists and is part of the project workflow.
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections when the project uses that file.

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

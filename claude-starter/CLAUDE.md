# Workflow Orchestration

This starter pack is intended to be installed as `.claude/` in the target repository.
All internal paths below assume that installed location.

## 1. Plan Mode Default

- Enter plan mode for any non-trivial task with 3 or more meaningful steps, cross-file changes, or architectural decisions.
- If the user asks for planning or uses the `planning:` prefix, use `.claude/agents/master-planner.md`.
- For planning-first work, follow `.claude/planning/protocol.md` as the source of truth for planning phases, user gates, artifact schemas, traceability, TDD policy, and handoff rules.
- During planning, do not implement code or hand work to execution subagents before the user approves the task packet.
- Require approval after the initial brief, after the contract packet, and before execution.
- When a planning artifact is ready for user review, print it inline in Claude so the user can read it there without opening another app.
- If something goes sideways, stop and re-plan immediately instead of pushing through drift.
- Use plan mode for verification steps, not just building.
- Write decision-complete specs up front to reduce ambiguity.

## 2. Subagent Strategy

- Use subagents liberally to keep the main context window clean.
- Offload research, exploration, and parallel analysis to subagents.
- For complex problems, use subagents to add focused parallel compute.
- Give one task per subagent for focused execution.
- Leverage skills whenever possible.
- In planning mode, keep one master planner. Planning skills are stage transforms, not peer planners.

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
- For behavior-changing work, prefer test-first validation and verify that implementation satisfies the planned contract and test cases.

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
- `.claude/agents/master-planner.md` is the only planning orchestrator.
- `.claude/skills/planning-*.md` are planning stage transforms.
- post-implementation validation belongs to review and test-quality agents, not the planner.

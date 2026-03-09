---
name: planning-initial
description: "Use this skill when the user starts with a vague request, rough direction, or partially formed idea and needs a structured planning brief before contracts or tasks are defined. This skill focuses on intent clarification, goals, constraints, assumptions, open questions, and the boundaries of what the planner will not guess."
---

# Planning Initial

Turn a rough request into a structured planning brief that is good enough to drive contract definition.

Read and follow:
- `.claude/planning/protocol.md`

## Inputs

- rough request
- existing revision notes when reworking the brief
- any approved upstream planning artifacts that still apply

## Boundaries

Do:
- produce the canonical `Initial Planning Brief` schema from the protocol
- assign `G-*`, `C-*`, `A-*`, and `Q-*` IDs
- capture user intent before interfaces
- make uncertainty explicit
- surface `Decisions Needed From You`
- state `What I Will Not Guess`

Do not:
- define interfaces
- define schemas in detail
- break the work into implementation tasks
- mutate workflow phase directly
- choose `user_gate`
- ask the user directly; return the gaps for the master planner to surface

## Workflow

1. Capture what the user told us.
2. Expand the planning dimensions.
3. Propose a working interpretation.
4. Separate constraints from assumptions.
5. Identify the open questions that materially affect design.
6. State the decisions needed from the user and what the planner will not guess.

## Output

Return:
- `Initial Planning Brief`

The final phase and `user_gate` decision belong to the master planner.

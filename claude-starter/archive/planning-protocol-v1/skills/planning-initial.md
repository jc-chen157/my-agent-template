---
name: planning-initial
description: "Use this skill when the user starts with a vague request, rough direction, or partially formed idea and needs a structured discovery artifact before contracts or tasks are defined. This skill focuses on intent clarification, goals, constraints, assumptions, open questions, non-goals, and success criteria."
---

# Planning Initial

Turn a rough request into a discovery artifact that is good enough to drive contract definition.

Read and follow:
- `.claude/planning/protocol.md`

## Inputs

- rough request
- existing revision notes when reworking the discovery artifact
- any approved upstream planning artifacts that still apply

## Boundaries

Do:
- produce the canonical `Discovery Output` schema from the protocol
- assign `G-*`, `C-*`, `A-*`, `Q-*`, `R-*`, and `D-*` IDs where needed
- capture user intent before solution design
- make uncertainty explicit
- define success criteria and non-goals clearly
- prepare the artifact for downstream problem challenge by the grilling reviewer
- surface `Decisions Needed From You`
- state `What I Will Not Guess`

Do not:
- define interfaces in detail
- define implementation schemas in detail
- break the work into implementation tasks
- mutate workflow phase directly
- choose `user_gate`
- ask the user directly; return the gaps for the master planner to surface

## Workflow

1. Capture what the user told us.
2. Expand the planning dimensions.
3. Propose a working interpretation of the problem.
4. Separate constraints from assumptions.
5. Identify the open questions that materially affect design.
6. State the success criteria and non-goals.
7. Surface the decisions needed from the user and what the planner will not guess.
8. Return a discovery artifact ready for problem challenge.

## Output

Return:
- `Discovery Output`

The final phase and `user_gate` decision belong to the master planner.

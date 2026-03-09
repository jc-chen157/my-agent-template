---
name: master-planner-core
description: Use this project-local skill when the user wants planning before implementation. It orchestrates the workflow from initial brief through contract packet and task packet, then hands approved work to execution skills. This skill is self-contained inside `codex/` so it can be copied to a new repository as part of the whole Codex starter pack.
---

# Master Planner Core

Use this skill when the task is:

- planning or scoping before implementation
- turning a request into explicit planning artifacts
- keeping implementation paused until a task packet is approved

Read first:

- `references/planning-protocol.md`

Use fixtures as needed:

- `references/master-planner-transcript-fixtures.md`
- `references/traceability-sample.md`

Workflow:

- treat planning as one orchestrated workflow, not multiple peer planning agents
- follow the protocol phases, user gates, traceability rules, task sizing guardrails, and TDD policy
- produce the canonical artifacts defined in the protocol:
  - `Initial Planning Brief`
  - `Contract Packet`
  - `Task Packet`
- do not implement code while operating as the planner
- do not hand work to execution until the task packet is approved
- preserve traceability IDs across revisions when meaning stays the same

Stage responsibilities:

- Initial brief:
  - clarify goal, constraints, known context, assumptions, open questions, and non-goals
  - stop for approval after the brief
- Contract packet:
  - define the minimum viable readable interfaces, call flows, behavior rules, and `TC-*` contract test cases
  - carry forward planning context and assign risk level
- Task packet:
  - decompose the approved contract into decision-complete tasks
  - link tasks to planning IDs and `TC-*` test cases
  - use test-first sequencing when TDD is required
  - enforce task sizing guardrails

Rules:

- do not auto-advance past required approval checkpoints
- do not treat `readiness` as user approval
- do not drop constraints, known context, assumptions, or non-goals across stages
- do not guess missing design decisions; surface them explicitly
- if the plan drifts later, route the revision back to the correct artifact instead of silently changing the contract

After planning approval, switch to the appropriate execution skill:

- `backend-engineer-core` plus the matching stack skill for backend work
- `frontend-engineer-core` plus the matching stack skill for frontend work
- reviewer or test-quality skills for post-implementation validation

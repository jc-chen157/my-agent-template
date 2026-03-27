---
name: planning-break-down-plan
description: "Use this skill when an approved contract packet already exists and the next step is to decompose the work into a task packet with dependencies, touched surfaces, serial versus parallel lanes, and explicit task sizing guardrails."
---

# Planning Break Down Plan

Turn an approved contract packet into a decision-complete task packet for implementation.

Read and follow:
- `.claude/planning/protocol.md`

## Inputs

- approved `Contract Packet`
- revision notes when updating an existing task packet
- any prior task packet that should preserve stable task IDs

## Boundaries

Do:
- produce the canonical `Task Packet` schema from the protocol
- default to serial execution
- parallelize only when independence is explicit
- keep tasks self-contained enough for execution subagents
- make the main task body human-readable first
- plan test-first sequencing for `tdd_mode: required` work
- enforce the task sizing guardrails from the protocol
- summarize each task as what, why, deliverables, done-when, and how-to-verify
- carry forward the edge cases, failure paths, and relevant recovery expectations from the contract into each task
- carry forward traceability to `G-*`, `C-*`, `D-*`, `R-*`, and `TC-*`
- summarize what requires user approval before execution

Do not:
- redefine the contract
- invent new requirements silently
- re-litigate approved design choices unless a task-sizing problem reveals contract drift
- validate completed implementation
- mutate workflow phase directly
- choose `user_gate`
- ask the user directly; return the gaps for the master planner to surface

## Workflow

1. Map contract commitments to work units.
2. Identify touched surfaces.
3. Build the dependency graph.
4. Decide serial versus parallel.
5. Map relevant edge cases, failure paths, and recovery expectations to the tasks that must handle them.
6. Map `TC-*` cases into test-first execution order when TDD is required.
7. Split oversized work using the task sizing rules.
8. Write each task in plain language for a human implementer.
9. Add a compact task coverage summary table.
10. Produce the task packet and approval summary.

## Output

Return:
- `Task Packet`

The final phase and `user_gate` decision belong to the master planner.

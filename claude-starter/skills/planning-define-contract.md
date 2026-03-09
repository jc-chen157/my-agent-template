---
name: planning-define-contract
description: "Use this skill after an initial planning brief exists and the next step is to define the minimum viable contract packet for implementation. This skill focuses on readable interfaces, call flows, behavior rules, error cases, and `TC-*` contract tests without low-level internal ID taxonomies."
---

# Planning Define Contract

Turn a planning brief into an implementation-facing contract packet.

Read and follow:
- `.claude/planning/protocol.md`

## Inputs

- approved `Initial Planning Brief`
- revision notes when updating an existing contract
- any prior contract packet that should preserve stable IDs

## Boundaries

Do:
- produce the canonical `Contract Packet` schema from the protocol
- preserve carried-forward `G-*`, `C-*`, `A-*`, and `Q-*` context
- use plain-language names for interfaces, flows, and behaviors
- describe each contract item in terms of what it does and why it exists
- define `TC-*` contract test cases for the behaviors that must be proven
- prefer minimum viable contracts over speculative design
- treat behavior as first-class
- assign `risk_level` using the protocol rules
- surface `Decisions Needed From You`
- state `What I Will Not Guess`
- end with a compact goals-and-coverage table

Do not:
- decompose implementation work into tasks
- choose execution order
- validate completed work
- mutate workflow phase directly
- choose `user_gate`
- introduce low-level ID taxonomies for interfaces, methods, or flows
- ask the user directly; return open questions for the master planner to surface

## Workflow

1. Carry forward the user intent and planning constraints explicitly.
2. Define the minimum readable interfaces.
3. Define the call flows and behavior rules.
4. Define the error cases and data shapes only where they matter.
5. Define `TC-*` contract test cases in plain language: what is tested, how it is checked, and pass/fail criteria.
6. Evaluate contract risk.
7. Surface remaining assumptions, user decisions, and non-guess boundaries.
8. Add a compact goals-and-coverage summary table.

## Output

Return:
- `Contract Packet`

The final phase and `user_gate` decision belong to the master planner.

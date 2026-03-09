# Master Planner Transcript Fixtures

Use these fixtures to sanity-check the planning workflow without editing code.

## Fixture 01: Vague Request Stops After Initial Brief

Intent:
- verify that a vague request produces an `Initial Planning Brief`
- verify that the master planner pauses at the required approval gate

Expected behavior:
- `Current Phase` is `brief_ready`
- `Artifact Produced` is `Initial Planning Brief`
- `User Gate` is `needs_approval`
- the brief includes `Assumptions`, `Open Questions`, `Decisions Needed From You`, and `What I Will Not Guess`
- the planner does not generate a contract packet before approval

## Fixture 02: Missing Material Input Uses Blocked

Intent:
- verify that the planner blocks only when missing context materially changes the design

Expected behavior:
- `Current Phase` is `blocked`
- `User Gate` is `needs_input`
- `What I Need From You` names the exact missing decision
- the planner explains why that missing input materially changes the contract or task packet

## Fixture 03: Contract Review Stops For Manual Validation

Intent:
- verify that the planner always stops after the contract packet for manual user review

Expected behavior:
- the `Contract Packet` is printed inline in the Claude console
- `Current Phase` is `contract_ready`
- `User Gate` is `needs_approval`
- the planner does not continue to task packet generation until the user approves the contract
- the contract sections read as plain-language summaries, not dense cross-references

## Fixture 04: High-Risk Contract Requires Approval

Intent:
- verify that high-risk or externally visible changes force a contract approval gate

Expected behavior:
- the `Contract Packet` sets `Risk Level: medium` or `high`
- `Current Phase` is `contract_ready`
- `User Gate` is `needs_approval`
- the full contract is printed inline for review
- the planner stops before task breakdown

## Fixture 05: Task Packet Enforces Sizing

Intent:
- verify that the task packet stays small enough for focused execution

Expected behavior:
- oversized work is split before execution handoff
- one task does not mix multiple architectural decisions
- test work is split from implementation work when TDD is required
- each task reads as a short implementation checklist rather than a traceability record

## Fixture 06: Planner Surfaces Non-Guess Boundaries

Intent:
- verify that the planner forces clarity instead of guessing

Expected behavior:
- every artifact includes `Assumptions`
- every artifact includes `Decisions Needed From You`
- every artifact includes `What I Will Not Guess`
- low-impact preferences are carried as assumptions instead of blocking
- the contract ends with a table showing goals/design items and how they are covered
- the task packet ends with a compact task coverage table instead of inline ID-heavy bullets

## Regression Checklist

The master planner must never:
- delegate execution before the task packet is approved
- drop `Constraints`, `Known Context`, `Assumptions`, or `Non-Goals` across artifacts
- let a planning skill decide the workflow phase or `user_gate`
- skip `TC-*` definition for behavior-changing contract work
- decompose code-bearing work without linked test cases when TDD is required
- perform post-implementation validation inside the planning workflow

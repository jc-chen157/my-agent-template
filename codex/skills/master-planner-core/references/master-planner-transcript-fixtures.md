# Master Planner Transcript Fixtures

Use these fixtures to sanity-check the planning workflow.

## Fixture 01: Vague Request Stops After Initial Brief

Expected behavior:
- produce an `Initial Planning Brief`
- report `Current Phase: brief_ready`
- report `User Gate: needs_approval`
- stop before generating a contract packet

## Fixture 02: Missing Material Input Uses Blocked

Expected behavior:
- report `Current Phase: blocked`
- report `User Gate: needs_input`
- name the exact missing decision
- explain why the missing input materially changes the design

## Fixture 03: Contract Review Stops For Manual Validation

Expected behavior:
- the `Contract Packet` is printed inline in the Claude console
- report `Current Phase: contract_ready`
- report `User Gate: needs_approval`
- task breakdown does not proceed until the user approves the contract

## Fixture 04: High-Risk Contract Requires Approval

Expected behavior:
- `Risk Level: medium` or `high`
- report `Current Phase: contract_ready`
- report `User Gate: needs_approval`
- print the full contract inline for review
- stop before task breakdown

## Fixture 05: Task Packet Enforces Sizing

Expected behavior:
- oversized work is split before handoff
- one task does not mix multiple architectural decisions
- test work is split from implementation work when TDD is required
- each task reads as a short implementation checklist rather than a traceability record

## Fixture 06: Planner Surfaces Non-Guess Boundaries

Expected behavior:
- every artifact includes `Assumptions`
- every artifact includes `Decisions Needed From You`
- every artifact includes `What I Will Not Guess`
- low-impact preferences are carried as assumptions instead of blocking
- the task packet ends with a compact task coverage table instead of inline ID-heavy bullets

## Regression Checklist

The planner must never:
- delegate execution before the task packet is approved
- drop `Constraints`, `Known Context`, `Assumptions`, or `Non-Goals` across artifacts
- skip `TC-*` definition for behavior-changing contract work
- decompose code-bearing work without linked test cases when TDD is required
- perform post-implementation validation inside the planning workflow

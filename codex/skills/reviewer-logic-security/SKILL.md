---
name: reviewer-logic-security
description: Use this skill for correctness and security reviews. It focuses on bug risk, unsafe assumptions, concurrency hazards, resource leaks, trust boundaries, validation, auth, and exploit paths. It does not do maintainability review or broad test-quality review.
---

# Reviewer Logic Security

Use this skill when the review goal is:

- logical correctness
- boundary-condition bugs
- stale state and invalid state transitions
- concurrency hazards and lifecycle bugs
- resource leaks
- trust-boundary mistakes
- validation, auth, authz, and exploit paths

Out of scope:

- naming and readability review
- abstraction and maintainability review
- broad test-quality review

Route those to:

- `reviewer-best-practice`
- `reviewer-test-quality`

Review heuristics:

- incorrect control flow
- missing cleanup
- race conditions and ordering assumptions
- missing validation
- injection, exposure, or privilege-escalation paths
- risky behavior hidden by insufficient verification

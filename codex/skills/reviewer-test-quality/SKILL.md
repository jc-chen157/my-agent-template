---
name: reviewer-test-quality
description: Use this skill for test and verification reviews. It focuses on missing scenarios, weak assertions, flaky structure, over-mocking, and whether the changed behavior is actually proved well enough. It does not do general maintainability review or deep logic/security analysis except as they relate to verification gaps.
---

# Test Engineer

Use this skill when the review goal is:

- missing scenarios
- weak assertions
- low-signal or over-mocked tests
- flaky structure
- hidden shared state or timing dependence
- insufficient proof for intended behavior

Out of scope:

- production-code maintainability review
- deep logic bug hunting not tied to verification
- full security review beyond identifying what needs explicit tests

Route those to:

- `code-review-engineer-core`

Pair this reviewer with the matching testing skill when the stack is known:

- `java-testing`
- `python-testing`
- `go-testing`
- `rust-testing`
- `typescript-testing`

Review heuristics:

- happy path only, no failure-path proof
- missing edge cases and boundaries
- assertions that would still pass after a regression
- fixture setup that obscures the scenario
- tests coupled to implementation detail instead of behavior

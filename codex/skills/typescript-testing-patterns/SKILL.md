---
name: typescript-testing-patterns
description: Use this skill for TypeScript testing patterns. It provides guidance for Vitest-style testing, module mocking, async assertions, parameterized tests, and behavior-first test structure.
---

# TypeScript Testing Patterns

Use this skill when reviewing or writing TypeScript tests.

Guidance:

- Prefer behavior-focused assertions over implementation-detail checks.
- Use parameterized tests where behavior matrices exist.
- Keep module mocking narrow and reset mock state cleanly.
- Prefer network-level mocking for HTTP boundaries when appropriate.
- Be explicit about async expectations and always await async assertions.
- Use typed helpers to keep fixtures and expectations honest.

Review heuristics:

- snapshot overuse with weak behavioral assertions
- mock-heavy tests that lock in internals
- async assertions that are not awaited
- tests tightly coupled to hook/component/private-function internals
- missing coverage for error states, retries, or stale data behavior

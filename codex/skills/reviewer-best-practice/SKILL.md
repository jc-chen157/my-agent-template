---
name: reviewer-best-practice
description: Use this skill for maintainability and design-quality reviews. It focuses on readability, naming, abstraction quality, boundaries, framework idioms, duplication, and long-term code health. It does not do deep logic/security review or broad test-quality review.
---

# Reviewer Best Practice

Use this skill when the review goal is:

- readability
- maintainability
- cohesion and separation of concerns
- abstraction quality
- module and API boundaries
- language and framework idioms
- duplication and change cost

Out of scope:

- logic bugs
- security vulnerabilities
- broad test-quality review

Route those to:

- `reviewer-logic-security`
- `reviewer-test-quality`

Review heuristics:

- unclear ownership of responsibilities
- leaky abstractions
- bloated modules, components, or functions
- naming that hides intent
- unnecessary indirection or overengineering
- local violations of language/framework conventions

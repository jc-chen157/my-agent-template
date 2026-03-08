---
name: node-nextjs-backend
description: Use this skill for TypeScript backend work in Node.js or Next.js and for code review in those stacks. It provides stack-specific guidance for Node.js runtime behavior and Next.js App Router backend patterns.
---

# Node Next.js Backend

Use these defaults:

- TypeScript
- Node.js
- Next.js App Router

Guidance:

- Keep the event loop free of heavy synchronous work.
- Keep server and client boundaries explicit.
- Use Route Handlers for HTTP interfaces.
- Use Server Actions for UI-driven mutations, not as a generic replacement for all backend code.
- Keep domain logic in plain server-side modules.
- Be explicit about caching, revalidation, auth, and serialization constraints.

Review heuristics:

- Event-loop blocking
- Route Handlers or Server Actions doing too much
- Server/client boundary confusion
- Weak request validation
- Accidental caching behavior
- Tight coupling between framework entrypoints and core logic

# Node Next.js Backend Skill

Use this skill with `backend-engineer` or `code-review-engineer` when the project is TypeScript backend work in Node.js or Next.js.

## Stack Defaults

- TypeScript
- Node.js
- Next.js App Router

## Implementation Guidance

- Keep the event loop free of heavy synchronous work.
- Keep server and client boundaries explicit.
- Use Route Handlers for HTTP interfaces.
- Use Server Actions for UI-driven mutations, not as a generic replacement for all backend code.
- Keep domain logic in plain server-side modules.
- Be explicit about caching, revalidation, auth, and serialization constraints.

## Review Heuristics

- Event-loop blocking
- Route Handlers or Server Actions doing too much
- Server/client boundary confusion
- Weak request validation
- Accidental caching behavior
- Tight coupling between framework entrypoints and core logic

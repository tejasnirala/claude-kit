# Engineering standards (every language, every project)

Code should be production-ready, readable and testable — easy for another senior engineer, a junior, or an
intern to pick up. When the repo's conventions differ from this file, the repo wins.

## Principles, applied pragmatically
- **KISS** — the simplest thing that correctly solves the problem. Readable beats clever or terse.
- **DRY** — one source of truth per concept (types/schemas, constants, endpoints, env, permission codes).
  Copied the same block a second time? Extract it. But don't merge two things that only look alike.
- **YAGNI** — build what the task needs. No speculative options, props, columns, config or abstraction layers
  "for later". Three similar lines are fine; abstract on the third real use, not the first.
- **Single responsibility / separation of concerns** — thin entry points (route handler, page, screen) that
  delegate to services/hooks; business logic doesn't know about HTTP; persistence doesn't know about UI.
- **Fail fast, fail closed** — validate at the boundary; when context is missing (no user, no tenant, no
  permission), return nothing rather than everything.

## Before writing new code
- Search for an existing helper, hook, component, type, schema or constant first (`grep`/`rg` for the concept,
  not just the name). Extend it rather than creating a near-duplicate.
- Read the file you'll change and one sibling that does the same kind of thing well. Match its structure,
  naming, error handling and comment density.

## Naming and structure
- Names say what something is or does; no abbreviations that aren't universal. Booleans read as questions
  (`isLoading`, `hasAccess`, `canEdit`). Functions are verbs.
- Match the casing already used in the folder (components `PascalCase`, hooks `useX`, constants `UPPER_SNAKE`,
  files matching their main export or the folder's existing pattern).
- No god files: when a file mixes several responsibilities or passes ~300 lines, split along a real seam.
- No magic values: named constants or config for numbers/strings that carry meaning (timeouts, limits, roles,
  status codes, routes, user-visible copy when the project centralises it).

## Errors
- Handle errors explicitly at the level that can do something about them; let the rest propagate.
- Never swallow an error silently (`catch {}`), never `catch` just to re-throw the same thing.
- Errors that reach users are plain language ("Couldn't save. Check your connection and try again."), never raw
  codes or stack traces. Errors that reach logs carry context (ids, operation) but never secrets or personal data.
- Use the project's typed/structured error helpers if it has them, rather than ad-hoc status codes.

## Comments
- Explain **why**, not what. Comment non-obvious decisions, invariants, workarounds (with a link to the issue),
  and anything security-relevant. Delete comments that restate the code. No commented-out code.

## Dependencies
- Use what's installed first. A new dependency needs: a one-line reason, a check that it's maintained and sized
  sensibly, and (mobile) New Architecture + Expo compatibility. Call it out in the summary.
- Install with the repo's package manager (`npx expo install` for Expo projects so versions match the SDK).

## Configuration and secrets
- Read environment variables in one config module, validated at startup (e.g. Zod); nowhere else.
- Anything exposed to the client (`NEXT_PUBLIC_*`, `EXPO_PUBLIC_*`) is public — never a secret.
- New env var → add it to `.env.example` with a comment.

## Performance, in proportion
- Avoid the obvious traps (N+1 queries, request waterfalls, unbounded lists, work on every render, blocking the
  main/JS thread). Don't micro-optimise without a measurement.

## Logging
- Use the project's logger, not `console.log`. Log identifiers, not personal data (user id yes; name, email,
  phone, health or payment data no). Never log tokens, passwords, keys or full request bodies.

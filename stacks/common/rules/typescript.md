---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.cts"
---

# TypeScript

## Compiler stance
- `strict: true` is the floor. Prefer also `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` when the repo
  has them — respect them, don't work around them.
- No new `any`, `as any`, `@ts-ignore`, or non-null `!` to silence an error. Use `unknown` + narrowing (type guards,
  `in`, `instanceof` for your own classes, Zod `.parse`/`.safeParse` for external data). If an escape hatch is
  truly needed, `@ts-expect-error` with a one-line reason.
- `noUncheckedIndexedAccess`: `arr[0]` and `const [first] = rows` are `T | undefined` — check, don't assert.
- `exactOptionalPropertyTypes`: omit optional keys with a conditional spread `...(v ? { key: v } : {})`, never
  `{ key: undefined }`.

## Types
- **Types come from one source.** Derive rather than duplicate: `z.infer<typeof schema>` for validated data, the
  ORM's generated types for persistence, shared contracts package for API shapes. Never hand-copy an interface that a
  schema already defines.
- `type` for unions/intersections/mapped types; `interface` for object shapes that are extended — follow the repo's habit.
- Model states explicitly with discriminated unions (`{ status: 'loading' } | { status: 'error'; error: E } | …`)
  instead of several optional booleans.
- `as const` objects + `typeof X[keyof typeof X]` (or the repo's enum style) for fixed sets of values; avoid TS `enum`
  unless the repo uses them.
- Use `satisfies` to check a literal against a type without widening it.
- Public functions have explicit parameter and return types; internals can rely on inference.
- Branded/nominal types for ids that must not be mixed (`UserId` vs `OrgId`) when the repo uses them.

## Runtime boundaries
Everything crossing a trust boundary is `unknown` until validated: request bodies, query/params, env vars, `JSON.parse`,
`localStorage`/AsyncStorage, third-party API responses, webhook payloads, deep-link params. Validate with Zod (or the
repo's validator) once, at the boundary, and pass typed data inward.

## Errors and async
- `catch (err)` is `unknown` — narrow before reading properties. Narrow library errors structurally (`err.name`,
  `err.code`) when class identity can differ across packages (e.g. Prisma in monorepos).
- Every promise is awaited, returned, or explicitly `void`-ed with a reason; no floating promises. Independent awaits
  run in parallel (`Promise.all` / `Promise.allSettled`).
- Throw `Error` subclasses (or the project's typed errors), never strings.

## Modules
- Follow the repo's module style. ESM with `"type": "module"`/NodeNext → relative imports carry the `.js` extension
  even from `.ts` source. Use the configured path alias (`@/…`) instead of deep relative paths.
- Import types with `import type` when the repo uses `verbatimModuleSyntax`/`isolatedModules`.
- No default exports except where a framework requires them (Next.js pages/layouts, expo-router routes) — unless the
  repo already uses them consistently.
- Avoid barrel files that re-export large modules into client bundles.

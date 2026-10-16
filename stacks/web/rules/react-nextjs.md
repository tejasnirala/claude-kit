---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/app/**"
  - "**/components/**"
  - "**/hooks/**"
  - "next.config.*"
  - "tailwind.config.*"
  - "**/*.css"
---

# React & Next.js (App Router)

Stack defaults (the repo's choices win): Next.js App Router · React 19 · TypeScript strict · Tailwind ·
TanStack Query (client server-state) · Zustand (small client state) · react-hook-form + Zod · Jest/Vitest + React
Testing Library · Playwright for critical E2E.

**Next.js changes between majors.** Check the installed version and read `node_modules/next/dist/docs/` before relying
on memory (e.g. Next 16 renamed `middleware.ts` → `proxy.ts`; `params`/`searchParams` are async; caching defaults
changed in 15).

## Structure
- `app/` holds routing files only (`page`, `layout`, `loading`, `error`, `not-found`, `route`); pages stay thin and
  render feature components. Feature code in `features/<feature>/` (or the repo's `components/` + `hooks/` layout).
- Server-only modules (DB access, secrets) import `server-only`; never import them from client components.
- One component per file for anything non-trivial; co-locate its test and styles.

## Server vs client
- **Server Components by default.** Add `"use client"` only for state, effects, event handlers or browser APIs — and
  push the boundary as low in the tree as possible (a client button inside a server page, not a client page).
- Props crossing to client components must be serialisable; never pass secrets or whole DB records.
- Fetch data on the server when possible; run independent fetches in parallel; stream slow sections with `<Suspense>`.
- Server actions and route handlers are **public endpoints**: authenticate, authorise the object, and Zod-validate
  inside each one.
- Be explicit about caching/revalidation for per-user data — never serve one user's data from a shared cache.

## Components and hooks
- Function components with typed props; no components defined inside other components.
- Rules of hooks; correct effect dependencies; **don't use effects to derive state** — compute during render or use
  `useMemo` for expensive derivations; effects are for synchronising with external systems.
- Lift state only as far as needed; context for rarely-changing values (theme, session), Zustand selectors for shared
  client state, TanStack Query for anything from the server (stable query-key factory, invalidate on mutation).
- Memoise (`memo`/`useMemo`/`useCallback`) where it prevents measurable re-renders, not by reflex (React Compiler, if
  enabled, handles most of this — check before adding manual memoisation).
- Lists have stable keys (ids, never array indexes for dynamic lists).

## Forms
react-hook-form + `zodResolver` with the same Zod schema the server uses; labels on every field; inline errors
linked via `aria-describedby`; pending/disabled submit; server errors mapped back to fields; no double submit.

## UI states and quality
- Every data-driven view has loading (skeleton), **empty** (with the next action), error (with retry) and success
  states. Use `loading.tsx`/`error.tsx`/`not-found.tsx` for route-level states.
- Accessibility to WCAG 2.2 AA: semantic HTML, one `h1`, labelled controls, keyboard operable, visible focus, focus
  management in dialogs, contrast in both themes, `alt` on every `next/image`.
- Responsive from 320px; dark mode via design tokens (no hard-coded colours); `prefers-reduced-motion` respected.
- Tailwind: use theme tokens and the repo's `cn()` helper; extract a component instead of repeating long class lists.

## Performance
`next/image` (with `sizes`), `next/font`, `next/dynamic` for heavy client widgets, no barrel imports of big
libraries, avoid request waterfalls, keep client bundles small. Consult the `vercel-react-best-practices` skill when
writing or reviewing data fetching, rendering or bundle-sensitive code.

## Security
No secrets in `NEXT_PUBLIC_*`; no `dangerouslySetInnerHTML` without sanitising; no personal data in `localStorage`,
URLs or analytics; cookies `HttpOnly`/`Secure`/`SameSite`; CSRF protection for cookie-auth mutations outside server actions.

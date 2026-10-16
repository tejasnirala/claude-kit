---
name: new-page
description: Add a new page, route or screen to a Next.js App Router (React) app following the repo's patterns — route segment and layout, server vs client component split, data fetching (server fetch / TanStack Query) and mutations (server actions / API + invalidation), react-hook-form + Zod forms, loading/empty/error/not-found states, metadata/SEO, auth and authorisation, accessibility, responsive and dark mode, performance, and tests. Use whenever adding or substantially rebuilding a web page or dashboard screen. Invoke with /new-page <route-or-name>.
---

# New web page (Next.js App Router)

**Page:** $ARGUMENTS

If the project has its own `add-page`/`new-page` skill, use it. Otherwise follow this, mirroring the closest existing
page in the repo. Check the installed Next.js version (`package.json`) and read its docs in
`node_modules/next/dist/docs/` when unsure — behaviour changes between majors (e.g. Next 16 `proxy.ts`, async
`params`/`searchParams`, caching defaults).

## 1. Route and layout
- Segment under `app/` matching the URL; route groups `(group)` for shared layouts without URL impact; dynamic
  `[id]`, catch-all `[...slug]`. Shared chrome in the nearest `layout.tsx`, not duplicated in pages.
- Files: `page.tsx` (thin), `loading.tsx` (skeleton matching the layout), `error.tsx` (client, with reset/retry),
  `not-found.tsx` when the resource can be missing (`notFound()` from the page).
- Page logic lives in feature components/hooks (`features/<feature>/` or the repo's equivalent), not in `page.tsx`.

## 2. Auth and authorisation
- Protected? Enforce on the server: in the page/layout (session check → `redirect('/login')`) **and** in every data
  function/server action it calls (object-level: the record belongs to this user/tenant). Middleware/`proxy.ts` alone
  is not authorisation.
- Role-based UI hides actions the user can't take — but the server still checks.

## 3. Data
- **Server components by default.** Fetch on the server (directly from a server-only data module or the API); run
  independent fetches in parallel (`Promise.all`) — no waterfalls; stream slow parts with `<Suspense>`.
- Client interactivity (filters, infinite scroll, live updates) → a small `"use client"` component using TanStack Query
  with a key factory; hydrate from server data when it helps.
- Mutations: server actions (with Zod validation + auth inside) or API routes; then `revalidatePath`/`revalidateTag`
  or TanStack Query invalidation; optimistic UI for quick actions.
- Be explicit about caching for the installed Next version (static vs dynamic, `revalidate`, `cache: 'no-store'` for
  per-user data). Never cache per-user data in a shared cache.

## 4. Forms
react-hook-form + `zodResolver` with the **same Zod schema** the server validates with; field-level errors linked to
inputs; disabled + pending state on submit (`useFormStatus`/`isSubmitting`); server errors mapped back onto fields;
success feedback; no double-submit.

## 5. States (designed, not afterthoughts)
Loading (skeleton), **empty** (explains and offers the next action), error (plain language + retry), not-found,
success; long lists paginated or virtualised; optimistic and pending states for mutations.

## 6. UI quality
- Design system components and tokens (Tailwind theme / shadcn / the repo's library); no one-off colours.
- Responsive from 320px up; dark mode via tokens; respects `prefers-reduced-motion`.
- Accessibility: semantic elements, one `h1`, labelled controls, keyboard and focus management for dialogs/menus,
  contrast in both themes (the `web-accessibility-reviewer` agent checks this).
- New visual direction → load the `frontend-design` skill first; motion → design-eng skills.

## 7. Metadata and SEO
`export const metadata` / `generateMetadata` (title, description, canonical, Open Graph) for public pages; `noindex`
for private/dashboard pages; structured data where it matters; update the sitemap for new public routes.

## 8. Performance
`next/image` with sizes, `next/font`, `next/dynamic` for heavy client-only widgets (charts, editors, maps), no barrel
imports of large libraries, keep `"use client"` boundaries low in the tree. Cross-check with the
`vercel-react-best-practices` rules.

## 9. Tests
Component tests (React Testing Library) for the interactive parts and states; server action / route handler tests for
validation and authorisation negatives; Playwright E2E for the critical path if the repo has it.

## 10. Verify
`verify` skill (lint → typecheck → tests), then load the page: happy path, empty state, error state (simulate), logged
out, another user's resource (must 404/403), mobile width, dark mode, keyboard-only pass. Check browser console and
server logs for errors/hydration warnings.

## Report
Route + files · data/caching approach · states implemented · checks done · anything not verified.

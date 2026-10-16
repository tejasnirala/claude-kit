# <Project name>

Context for Claude Code sessions on this repository. Read this first, then the rule or doc for what you're touching.
Team workflow, agents and skills: `.claude/rules/workflow.md`. Stack rules: `.claude/rules/*.md` (load by file path).

## What this is
<2–4 sentences: what the product does, who uses it, the one or two things that make it unusual (multi-tenant? health
or payment data? real-time? public marketing site + app?).>

## Stack
- Web: Next.js <version> (App Router) · React <version> · TypeScript strict · Tailwind <version> · <UI library>
- Data: TanStack Query · Zustand · react-hook-form + Zod
- Backend: <Express 5 + Prisma + PostgreSQL in `apps/api` | Next.js route handlers/server actions + <ORM> | Spring Boot in `<path>`>
- Auth: <provider / approach>  ·  Hosting: <Vercel / …>  ·  Package manager: <pnpm | npm | bun>

## Where things are
| Path | What |
|---|---|
| `app/` | routes only (thin pages, layouts, loading/error states) |
| `features/<feature>/` | feature components, hooks, queries |
| `components/ui/` | design-system primitives |
| `lib/` | API client, utilities, config |
| `<api path>` | backend: routes → services → data |
| `<contracts path>` | shared Zod schemas / types — the single source of truth for API shapes |
| `<docs path>` | ADRs, status/roadmap |

## Commands
```bash
<pm> dev            # start web (and API?)
<pm> lint           # ESLint
<pm> format         # Prettier
<pm> typecheck      # tsc --noEmit
<pm> test           # unit/integration
<pm> test:e2e       # Playwright (critical paths)
<db commands: migrate / generate / seed>
```

## Invariants — breaking one is a bug, not a style choice
1. <e.g. Every query on user data is scoped by the caller's id/org inside the query.>
2. <e.g. API shapes come only from `<contracts path>`; never redefine on either side.>
3. <e.g. Money is integer minor units + currency.>
4. <e.g. Dates stored UTC, rendered in the user's timezone via `formatDate()` only.>
<Delete examples that don't apply; add the real ones as the project grows.>

## Conventions specific to this repo
- <Design direction: palette/typography/signature — set once, reused by every page.>
- <Naming, folder or state conventions that differ from the rules.>
- Commit format: <match history — e.g. `type: short lowercase summary`>. Deploys: <`main` → production?>

## Before you finish any task
```bash
<pm> lint && <pm> typecheck && <pm> test
```
Then load the page you changed (happy path, empty, error, logged-out, mobile width, dark mode).

## What NOT to do
- <Project-specific don'ts — e.g. never call the API from components directly; never hardcode endpoint URLs.>
- Never put secrets in `NEXT_PUBLIC_*`; never store personal data in `localStorage` or URLs.

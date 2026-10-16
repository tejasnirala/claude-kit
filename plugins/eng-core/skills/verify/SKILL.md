---
name: verify
description: Run the project's full check sequence once, in order — lint and format, then typecheck, then tests, then a runtime smoke check — auto-detecting npm/pnpm/yarn/bun, monorepos (turbo/nx), Expo, Next.js and Maven/Gradle, and report pass/fail with counts. Use after finishing a change, before committing, or when asked to "verify", "check", "make sure it passes", or "run the tests". Lighter than review-changes, which also runs reviewer agents.
---

# Verify

If the project has its own `verify` skill, a `check`/`validate` script, or a verification section in `CLAUDE.md`,
**use that** — it knows the repo's gates (RLS checks, API-doc coverage, Docker commands). This skill is the fallback.

Run once, at the end of the work — never between implementation steps. Stop at the first real failure, fix it, then
re-run from that step.

## 0. Detect the toolchain

- Package manager from the lockfile: `pnpm-lock.yaml` → `pnpm`, `yarn.lock` → `yarn`, `bun.lock(b)` → `bun`,
  `package-lock.json` → `npm`. Java: `./mvnw` or `./gradlew` (prefer the wrapper).
- Read `package.json` scripts (root and touched packages). Prefer an aggregate script if one exists:
  `check`, `validate`, `verify`, `ci`. Monorepo: `turbo run <task> --filter=<pkg>...` / `nx affected -t <task>`.
- Runs inside Docker? If `CLAUDE.md`/README says commands run via `docker compose exec <svc>`, do that, and check the
  stack is up (`docker compose ps`).
- Scope to what changed (`git diff --name-only`, `git diff --staged --name-only`) when the repo supports per-package
  runs; otherwise run the whole thing.

## 1. Lint and format

- JS/TS: `<pm> run lint` (or `eslint .`), then the formatter (`<pm> run format` / `prettier --check .`).
  If lint failed only on formatting, format and lint again.
- Java: `./mvnw spotless:check` / `./gradlew spotlessCheck` / checkstyle if configured.

## 2. Typecheck — no production build

- `<pm> run typecheck` or `tsc --noEmit` (per package in monorepos; limit concurrency if the machine/container is
  memory-constrained — exit code 137 means OOM, not a type error).
- Expo: `npx tsc --noEmit`, and `npx expo install --check` when dependencies changed (SDK version alignment).
- Next.js has no separate typecheck script? `tsc --noEmit` works; use `next build` only if nothing else typechecks.
- Java: `./mvnw -q compile` / `./gradlew compileJava` (compilation is the typecheck).

## 3. Tests — once

- `<pm> test` (add `--watch=false`/`--run`/`CI=1` so it doesn't hang in watch mode), or the touched package's tests.
- Java: `./mvnw test` / `./gradlew test` (integration tests: `verify` / `integrationTest` if separate).
- Long suites: run in the background and wait for completion rather than polling.
- Extra gates when relevant and present: DB checks (`prisma migrate status`, schema drift / RLS checks), API-doc
  coverage scripts, E2E (Playwright/Maestro/Detox) **only** if the change touches those flows and the user wants it.

## 4. Runtime smoke check (when the change has a runtime surface)

- API: start or reuse the dev server; `curl` the changed endpoint (one success, one unauthorised/invalid request).
- Web: load the changed page; check the browser console and server log for errors.
- Mobile: confirm the app bundles (`npx expo start` / `npx expo export --platform ios` for a quick bundle check);
  if a simulator is available, open the screen on **iOS first**, then Android. Native dependency added? A dev-client
  rebuild is needed — say so instead of claiming it works.

## Report

```
Verify: <scope>
1. Lint/format   ✅ | ❌ <first failing lines>
2. Typecheck     ✅ | ❌ <errors>
3. Tests         ✅ N passed (M suites) | ❌ <failing test names + assertion>
4. Runtime       ✅ <what you exercised> | skipped — <why>
<"All checks pass." or the list of what's still failing>
```

Never call something verified that was only edited; "skipped" with a reason is always acceptable.

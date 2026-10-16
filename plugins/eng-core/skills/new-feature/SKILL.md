---
name: new-feature
description: Build a complete end-to-end feature as a vertical slice following the repo's existing patterns — design with the architect agent, then schema + migration, shared contracts, backend (Express/Prisma or Spring Boot), permissions, web (Next.js) and/or mobile (Expo) UI with all states, tests, docs — and verify once at the end. Use when the user asks to add/build/implement a new feature, module, domain or CRUD resource. Invoke with /new-feature <feature-name>.
---

# New feature (vertical slice)

**Feature:** $ARGUMENTS

A feature is a vertical slice. It is **not done when the endpoint returns 200** — it's done when the UI handles
every state, the authorisation negatives are tested, docs are current, and verification has run.

If the project has its own `new-feature` skill or a documented feature workflow in `CLAUDE.md`, follow that instead —
it knows the repo's invariants. Use this one as the fallback.

## 1. Understand and clarify

1. Read `CLAUDE.md`, `.claude/rules/*`, and any status/roadmap doc (`STATUS.md`, tracker) — the feature may depend on
   something not built yet. Say so rather than inventing it.
2. Find the closest existing feature; read it end to end (schema → API → UI → tests). It is your template.
3. Ask only what changes the design (with your recommended answer for each):
   - Entity and operations (list / detail / create / update / delete / search / export)?
   - Ownership/scope: per user, per org/tenant, global? Who may do what (roles/permissions)?
   - Sensitive data (personal, health, payment)? Which fields?
   - Web, mobile, or both? Offline needed on mobile? Real-time?
   - Anything slow or external (email, push, PDF, payment, webhook) → background job?

## 2. Design — and stop for approval

Delegate to the **architect** agent: `design the <feature> feature`, passing your answers.
Present the design. **Wait for the user's OK** if it adds/changes schema, auth/permissions, payments, or public API
contracts (per global workflow). Smaller features: state the plan and proceed.

## 3. Implement every layer before verifying anything

Follow the design and the mirrored feature's patterns. Order:

1. **Schema & migration** — model with the repo's conventions (UUID PK, UTC timestamps, `deletedAt` soft delete,
   correct money type, scoped uniques, indexes for FKs and filters). Generate the migration with the repo's tool
   (`prisma migrate dev --name <x>`, `drizzle-kit generate`, a new Flyway `V<n>__<x>.sql`) and append any hand-written
   SQL (partial indexes, policies, backfills). Never edit an applied migration. Regenerate clients (`prisma generate`).
2. **Contracts** — request/params/response schemas in the shared location (shared Zod package, `types/`, DTOs,
   OpenAPI). Export inferred types; both sides import them — never redefine a shape.
3. **Permissions** — new permission codes/roles in the central place, referenced by constant, never string literals.
4. **Backend**
   - *Express/Node*: service functions (business logic, one transaction per unit of work, explicit owner/tenant
     scoping in every query) → route with the repo's middleware order (auth → authorisation → validation → handler) →
     typed errors via the project's error helpers → responses via its response helpers → mount the router.
   - *Next.js full-stack*: route handlers / server actions with their own auth + Zod validation; data access in a
     server-only module.
   - *Spring Boot*: entity + repository → service (`@Transactional`) → DTOs with Bean Validation → controller
     (`@Valid`, method security) → exception mapping in `@ControllerAdvice`.
   - Audit sensitive reads/writes if the project audits; idempotency keys for create/payment endpoints;
     background jobs for slow/external work.
   - Update the API docs/OpenAPI entry as part of the endpoint, not as a follow-up.
5. **Web UI** (if any) — route under the App Router; server components by default; data via the repo's pattern
   (server fetch or TanStack Query with stable keys + invalidation on mutation); forms with react-hook-form + the
   shared Zod schema; **loading, empty, error and success states designed as part of the screen**; accessible
   labels, focus and keyboard flow. New visual direction → load the `frontend-design` skill first.
6. **Mobile UI** (if any) — use the `new-screen` skill (mobile plugin) for each screen: iOS-first, accessible,
   performant, offline-tolerant, dark mode.
7. **Tests** (write now, run in step 4) — service/business logic unit tests; API integration tests including
   **authorisation negatives** (anonymous, other user/tenant, missing permission); component/screen tests for the main
   interaction and states. Use the `test-writer` agent for larger suites.
8. **Docs** — update what this feature makes stale: README/API docs/`.env.example`/CHANGELOG/STATUS tracker.

## 4. Verify once, at the end

Run the `verify` skill (lint+format → typecheck → tests → runtime check). Then exercise it for real: `curl` the
endpoint (happy path + one unauthorised call), load the page, open the screen on the iOS simulator (then Android).
Fix what falls out and re-run only the failed step onward.

Optionally run the `review-changes` skill for a reviewer pass before handing back.

## 5. Report

```
## Feature: <name>
Built: <bullets per layer, with key files>
Verified: lint ✅ typecheck ✅ tests ✅ (N passed) · runtime: <what you exercised>
Decisions: <notable choices + why>
Not done / follow-ups: <deliberately out of scope, risks, future improvements>
```

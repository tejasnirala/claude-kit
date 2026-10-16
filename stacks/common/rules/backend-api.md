---
paths:
  - "**/api/**"
  - "**/server/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/services/**"
  - "**/middleware*/**"
  - "**/prisma/**"
  - "**/*.prisma"
  - "**/drizzle/**"
  - "**/migrations/**"
  - "**/db/**"
  - "**/app/**/route.ts"
  - "**/actions/**"
---

# Backend & API (TypeScript default: Express 5 + Zod + Prisma + PostgreSQL)

The repo's existing framework and patterns win. These are the defaults and the non-negotiables.

## Layering
`route/controller` (HTTP: parse, validate, call service, shape response) → `service` (business logic, transactions,
authorisation of objects) → `repository/ORM` (data access). Business logic never touches `req`/`res`; routes never
contain business rules or raw queries. Shared request/response schemas live in one contracts location and both client
and server import them.

## Request pipeline (Express) — order is the security model
`helmet/cors → body parsing (size limit) → request id + logging → rate limit → authenticate → authorise →
validate → handler → error middleware`. Don't reorder. Always `return` after sending a response; forward errors with
`next(err)` (Express 5 forwards rejected promises automatically).

## Validation and contracts
- Validate body, params and query with Zod at the boundary; reject unknown keys for writes (`.strict()`); never spread
  a request body into an ORM `create`/`update` (mass assignment) — pick fields explicitly.
- Responses go through the project's response helpers / a consistent envelope; never return ORM entities with
  internal fields (password hashes, tokens, internal flags).

## REST conventions
- Plural resource nouns (`/v1/invoices/:id`), verbs only for actions that aren't CRUD (`/v1/invoices/:id/void`).
- Status codes: 200 OK · 201 Created (+ resource) · 204 No Content · 400 validation · 401 unauthenticated ·
  403 forbidden · 404 not found (also for "exists but not yours" when hiding existence) · 409 conflict ·
  422 business-rule violation (if the repo uses it) · 429 rate limited · 500 unexpected.
- Error body consistent: `{ error: { code: "INVOICE_ALREADY_PAID", message: "Human-readable", details? } }` (or the
  repo's shape). Stable machine codes; human messages without internals.
- Pagination on every list (cursor for feeds/large tables, page/limit otherwise) with a server-enforced max limit.
- Idempotency keys for create/payment endpoints that clients may retry. Mobile clients can't be force-updated —
  **never make breaking changes to an endpoint an app version in the wild uses**; add a new field/version instead.
- Every endpoint change updates its OpenAPI/API docs in the same change.

## Authorisation
Every handler on non-public data checks the caller **and** that the object belongs to them/their tenant, inside the
query (`where: { id, ownerId }`) — never fetch-by-id-then-forget-to-check. Permission codes come from one central
module. Unknown tenant → 404.

## Database (Prisma/Postgres defaults)
- UUID primary keys; `createdAt`/`updatedAt` as `timestamptz` (UTC in the DB, user's timezone only at render);
  soft delete with nullable `deletedAt` and every read filtering it.
- Money: integer minor units or `Decimal(14,2)` + currency column — never float. Quantities `Decimal` with explicit scale.
- Index every foreign key and every column used to filter/sort; uniqueness scoped per tenant/owner where relevant.
- Real join tables, not JSON arrays of foreign keys. JSON columns only for genuinely schemaless documents.
- Migrations: generate with the tool, append hand-written SQL Prisma doesn't manage (partial indexes, triggers,
  policies), **never edit an applied migration**, and keep them backwards compatible (expand → migrate → contract).
- One transaction per unit of work; no external HTTP calls inside a transaction; avoid N+1 (`include`/`select` the
  relation or batch); read-modify-write on counters/balances via atomic update, constraint or lock.
- Raw SQL only parameterised (`Prisma.sql` / tagged templates), never string interpolation.

## Reliability and operations
- Config from one validated module (Zod on `process.env` at startup); fail fast on missing config.
- Structured logging (pino or the repo's logger) with request id; log ids, never personal data or secrets; redact
  sensitive paths.
- Slow, external or retryable work (email, push, PDFs, webhooks) goes to a background job with an idempotency key and
  retry/backoff — not the request path.
- Webhooks: verify signature on the raw body first, then process idempotently.
- Timeouts on every outbound call; graceful shutdown closes the server, DB pool and queues.

---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
  - "**/tests/**"
  - "**/test/**"
  - "**/src/test/**"
  - "**/e2e/**"
---

# Testing

## When
- Every feature ships with tests for its logic; every bug fix ships with a regression test that **fails without the
  fix**. Write tests with the code; run them **once at the end** (lint → typecheck → tests), not between steps.
- Never claim tests pass without running them. Report counts and any failures with their output.

## What to test (value order)
1. Business rules and pure logic — money, dates/timezones, limits, permissions, state machines, validation schemas.
2. API / server actions — status codes, response shapes, validation errors, and **authorisation negatives**:
   anonymous → 401; another user's/tenant's record → 404 (or 403 per the project); missing permission → 403.
3. Data integrity — constraints actually enforced, soft-deleted rows excluded, pagination boundaries.
4. UI — the main interaction plus loading / empty / error states, queried by role/label (React Testing Library /
   React Native Testing Library). E2E (Playwright / Maestro / Detox) only for critical paths.

## How
- Behaviour through public interfaces, never private internals. One behaviour per test; the name states it
  (`rejects a refund larger than the payment`).
- Arrange–Act–Assert; factories for test data; no real-looking personal data.
- Deterministic: fake timers / fixed clock, seeded randomness, no sleeps, no order dependence, no live external network.
- Mock only at boundaries you don't own (third-party HTTP, email/push providers, native modules in RN tests).
  **Prefer a real database** (test container / docker compose DB) over mocking the ORM.
- Specific assertions on observable outcomes; avoid large snapshots.
- Keep tests next to the code or in the repo's existing test folders, using its naming and helpers.

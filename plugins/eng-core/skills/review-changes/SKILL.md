---
name: review-changes
description: Full pre-merge review of the current changes — runs automated checks, then the code-reviewer agent plus the specialist reviewers that apply (security-reviewer; React/Next.js performance rules; mobile performance, accessibility and security reviewers for React Native) — and produces one consolidated, de-duplicated report with must-fix items. Use before committing or opening a PR, or when asked for a "full review", "review everything", or "pre-merge check". Invoke with /review-changes [path|commit-range].
---

# Review changes (consolidated)

**Target:** $ARGUMENTS — defaults to uncommitted + staged changes. A commit range (`main...HEAD`) or path narrows it.

If the project has its own `code-review` skill, use that instead; it knows the repo's gates.

## 1. Collect the change set

```bash
git status --short
git diff --stat; git diff --staged --stat        # or: git diff --stat <range>
```
Classify touched files: **backend** (routes/services/schema/migrations, `*.java`), **web** (Next.js/React `app/`,
`components/`), **mobile** (Expo app: `app.json`/`app.config.*` present, `react-native` in deps), **infra/config**.
Note which areas are security-sensitive: auth, permissions, user/health/payment data, file upload, webhooks, crypto,
schema/migrations.

## 2. Automated checks (blocking)

Run lint and typecheck for the touched packages (see the `verify` skill for detection). Tests only if the user asked
for a full verification. Record pass/fail and new errors only.

## 3. Reviewers — run in parallel where possible, pass each the file list and diff

| Condition | Agent / skill |
|---|---|
| Always | `code-reviewer` |
| Security-sensitive files touched (see step 1), or any new endpoint | `security-reviewer` |
| Web React/Next.js components, data fetching or rendering touched | check against the `vercel-react-best-practices` rules (web plugin); cite rule ids |
| Mobile screens/components touched | `rn-performance-reviewer` and `mobile-accessibility-reviewer` (mobile plugin) |
| Mobile auth, storage, tokens, deep links, payments touched | `mobile-security-reviewer` (mobile plugin) |
| Animation/motion code touched | `review-animations` skill (design-eng plugin) |

Skip reviewers whose plugin isn't installed and say so.

## 4. Consolidate

Merge all findings, **remove duplicates** (same file:line, same root cause → keep the most severe wording), drop
anything without a concrete failure scenario, and order by severity then file.

```
## Review summary — <scope: N files, +X/−Y>

### Automated checks
- Lint: ✅ / ❌ (n new)    - Typecheck: ✅ / ❌ (n new)    - Tests: ✅ N passed / not run

### Must fix before merge
1. [CRITICAL] path:line — <issue> → <fix>   (source: security-reviewer)
2. [CRITICAL] ...

### Should fix
1. [WARNING] path:line — ...                 (source: code-reviewer)

### Performance / accessibility / UX
1. [async-parallel] path:line — ...          (source: vercel-react-best-practices)
2. [a11y] path:line — ...                     (source: mobile-accessibility-reviewer)

### Nice to have
- ...

Verdict: Block | Fix "Should fix" then merge | Ship it
```

Do not apply fixes unless the user asks. If asked to fix, fix CRITICAL first, re-run the affected checks, and report.

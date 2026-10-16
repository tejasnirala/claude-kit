# Git

## When
- Commit or push **only when I ask**. Never force-push `main`/`master`; never rewrite history that's been pushed.
- If I ask for a PR, branch first (`feat/<short-name>`, `fix/<short-name>`) — never commit straight to `main`.
- Before committing, `git status` and `git diff --staged`: commit only files that belong to this change.

## Who — commit as the developer, not as Claude
- Commits are authored as **the human developer**, using the identity the repo already uses
  (`git log --format='%an <%ae>' | sort | uniq -c | sort -rn | head -3`). If the local `user.name`/`user.email`
  don't match, set them **in that repo only** (`git config user.name …`), never globally without asking.
- **No `Co-Authored-By: Claude` trailer, no "Generated with Claude Code" line** in commits or PR descriptions.
  (claude-kit also blanks `attribution` in `~/.claude/settings.json`.)

## Message format
- **Match the repo's history first** (`git log --oneline -20`). Some repos use capitalised imperative sentences,
  some use prefixes — follow what's there.
- Default when the repo has no convention: `type(scope): short lowercase summary` — no trailing period, ≤ 72 chars.
  Types: `feat` · `fix` · `polish` (visual/UX refinement) · `refactor` (no behaviour change) · `perf` · `test` ·
  `docs` · `content` · `seo` · `chore` (deps/config/tooling) · `ci` · `build`.
- Body (when the change isn't obvious): one or two plain sentences on **what and why**, not how. Reference the
  issue if there is one.

## Shape of commits
- **Many small commits, one logical change each.** Don't bundle a refactor with a feature, or formatting with a fix.
  Collapse into one commit only when the whole change is genuinely small.
- A change and everything that must ship with it go together: schema change + its generated migration;
  `package.json` change + its lockfile; new env var + `.env.example`; endpoint change + its contract/types.
- Use the repo's package manager only — never add a second lockfile (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn,
  `bun.lock` → bun, `package-lock.json` → npm).
- Before committing, lint/format must pass (import order included) for the files you touched.

## Never commit
`.env*` (except `.env.example`), keys/certs/keystores (`*.pem`, `*.p8`, `*.jks`, `*.keystore`,
`google-services.json`/`GoogleService-Info.plist` when they contain secrets), build output, `node_modules`,
local editor/OS files, large binaries, or generated files the repo ignores.

## Pull requests
- Title in the same format as commits. Description: **What** (bullets), **Why**, **How to test** (exact steps),
  **Screenshots** for UI (iOS first for mobile), **Risks / follow-ups**.
- Keep PRs reviewable (roughly < 400 changed lines of real code); split otherwise.

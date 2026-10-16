# claude-kit

One command sets up a shared Claude Code configuration; one more adds a project's stack rules.
Nothing is copied around: global files are **symlinks** into the kit, project rules are **imports** of kit files.

```sh
npx github:tejasnirala/claude-kit              # global setup only (default)
claude-kit project rcln                         # add Claude setup for a project you've cloned
```

## What goes where

| Layer | Lives in | Reaches you via |
|---|---|---|
| **Global, shared** — CLAUDE.md, engineering + git rules, `claude-setup` skill | `global/` | symlinks in `~/.claude` |
| **Shared agents & skills** — architect, reviewers, debugger, test-writer, `/new-feature`, `/verify`, `/review-changes`, … | `plugins/` (a plugin marketplace) | `eng-core` + `design-eng` installed globally |
| **Shared per stack** — workflow, TypeScript, testing, backend-API, React/Next.js, React Native + iOS-first quality bar, Java/Spring rules | `stacks/<common\|web\|mobile\|java>/` | `@imports` in the project's git-ignored `CLAUDE.local.md` + stack plugins enabled for that project |
| **Project-specific** — the repo's `CLAUDE.md`, invariants, its own agents/skills, `.claude/kit.json` | the project repo (committed) | `git clone` — access to the repo = access to its setup |
| **Personal** — tone, voice-dictation notes, theme/model, personal plugins, backups of non-git project configs | `~/.claude/personal/` (separate private repo) | `claude-kit install --personal <git-url>` |

Why imports and not symlinks inside projects: Claude Code deliberately ignores symlinks in a project that point
outside the repo. An `@~/.claude/kit/...` import reads the kit file directly, so there's still a single copy and
`claude-kit update` changes every project at once. The first time you open a project, Claude Code asks once to allow
imports from outside the repo — accept it.

## Commands

| Command | Does |
|---|---|
| `claude-kit` / `claude-kit install [--personal <git-url>]` | Clone/update the kit at `~/.claude/kit`; symlink global files; merge `settings.base.json` (+ personal overlay) into `~/.claude/settings.json`; install global plugins and skills. **Nothing project-related.** |
| `claude-kit project <name\|path\|git-url> [--stack web\|mobile\|java …]` | Find the repo by name under `~` (or clone a URL); runs the global setup first if missing; reads stacks from `.claude/kit.json` (or detects them and writes it — commit it); writes the managed import block into `CLAUDE.local.md`; enables the stack plugins for this project only; git-ignores the local files via `.git/info/exclude`; creates `CLAUDE.md` from the stack skeleton only if the repo has none. Safe to re-run. |
| `claude-kit update` | Pull the kit (+ personal), re-apply global, refresh every project set up on this machine. |
| `claude-kit status` | Show global links and set-up projects. |
| `claude-kit unlink [path]` | Remove the kit block from a project's `CLAUDE.local.md`. |

`settings.json` is merged, not symlinked: Claude Code writes to it (`/config`, `/plugin`), and those writes must not
land in the shared kit.

## New teammate on one project (e.g. rcln)

```sh
# 1. Claude Code installed and logged in; access to the rcln repo
git clone git@github.com:tejasnirala/rcln.git && cd rcln
npx github:tejasnirala/claude-kit project .     # global setup + rcln's stack rules and plugins
claude                                           # accept "trust this folder" and "allow external imports"
```
They see only what rcln's repo contains plus the public kit — never other projects' configs.

## Per-project options — `.claude/kit.json` (committed)

```json
{ "stacks": ["web", "java"], "excludeRules": ["backend-api"] }
```
A project rule with the same file name in `.claude/rules/` always wins over the kit's.

## Changing the shared setup
- Edit files in `~/.claude/kit` (global files are symlinked, so `~/.claude/CLAUDE.md` *is* `global/CLAUDE.md`).
- Agents/skills: `plugins/<plugin>/agents|skills/`, bump the plugin `version`.
- Third-party vendored skills: `scripts/sync-upstream.sh` (see `plugins/UPSTREAM.md`).
- Commit + push; everyone runs `claude-kit update`.

---
name: claude-setup
description: Create, edit, or organize Claude Code configuration — subagents, skills, rules, CLAUDE.md, slash commands, hooks, MCP servers, settings/permissions — globally (~/.claude) or per project (.claude/). Use when asked to "add an agent", "make a skill", "add a rule", "create a command", "set up Claude for this project", or "where should this config go".
---

# Claude Code setup

## Global vs project — decide first
- **Global** (`~/.claude/…`): personal preferences that apply to every repo.
- **Project** (`<repo>/.claude/…`, `<repo>/CLAUDE.md`): repo-specific, committed and shared with the team.
- **Project-local** (`.claude/settings.local.json`, `CLAUDE.local.md`): personal, git-ignored.
If unclear, project-specific facts go in the project; habits/preferences go global.

## Where each thing lives

| Thing | Global path | Project path | Format |
|---|---|---|---|
| Instructions | `~/.claude/CLAUDE.md` | `CLAUDE.md` | Markdown, keep short |
| Rules (modular instructions) | `~/.claude/rules/*.md` | `.claude/rules/*.md` | Markdown; optional `paths:` frontmatter glob to scope |
| Subagents | `~/.claude/agents/*.md` | `.claude/agents/*.md` | Frontmatter: `name`, `description`, `tools`, `model` |
| Skills | `~/.claude/skills/<name>/SKILL.md` | `.claude/skills/<name>/SKILL.md` | Frontmatter: `name`, `description`; may bundle scripts/refs |
| Slash commands | `~/.claude/commands/*.md` | `.claude/commands/*.md` | Prompt body, `$ARGUMENTS`; optional `description`, `allowed-tools` |
| Hooks / permissions / env | `~/.claude/settings.json` | `.claude/settings.json` | JSON — use the `update-config` skill |
| MCP servers | `claude mcp add -s user …` | `.mcp.json` (`-s project`) | JSON |

## Templates

**Subagent** (`agents/<name>.md`):
```markdown
---
name: <kebab-name>
description: <what it does + when to use it — this drives auto-delegation>
tools: Read, Grep, Glob, Bash   # omit to inherit all tools
model: inherit                  # or sonnet / opus / haiku
---
<system prompt: role, step-by-step process, output format>
```

**Skill** (`skills/<name>/SKILL.md`) — for anything non-trivial, use the `skill-creator` skill instead:
```markdown
---
name: <kebab-name>
description: <what + trigger phrases; this is how Claude decides to load it>
---
<instructions; reference bundled files by relative path>
```

**Rule** (`rules/<topic>.md`):
```markdown
---
paths: ["src/**/*.ts"]   # optional; omit to always load
---
# <Topic>
- <short, imperative bullet>
```

**Slash command** (`commands/<name>.md`, invoked as `/<name> args`):
```markdown
---
description: <shown in /help>
---
<prompt using $ARGUMENTS>
```

## Choosing the right mechanism
- Always-true preference → rule or CLAUDE.md.
- Reusable multi-step procedure with reference material → skill.
- Task that should run in isolated context / parallel → subagent.
- Prompt you type often → slash command.
- "Every time X happens, do Y" (deterministic) → hook (`update-config` skill).

## After creating
- Keep descriptions specific — vague descriptions mean the agent/skill never triggers.
- Don't duplicate content across CLAUDE.md and rules.
- Tell the user the file path and how to invoke it (`/agents`, `/<skill>`, `/<command>`, `/memory`).

## This machine uses claude-kit
- Shared global config is in `~/.claude/kit/global/` (symlinked into `~/.claude`) — edit it there.
- Shared agents/skills: `~/.claude/kit/plugins/<plugin>/`. Shared per-stack rules: `~/.claude/kit/stacks/<stack>/rules/`.
- Project-specific config stays in the project repo; personal-only config in `~/.claude/personal/`.
- Never add kit files to a project by copying — `claude-kit project <name>` wires them in. See `~/.claude/kit/README.md`.

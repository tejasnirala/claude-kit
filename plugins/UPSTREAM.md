# Upstream sources (vendored, pinned)
Refresh with `scripts/sync-upstream.sh`, review the diff, bump plugin `version`, commit.

| Plugin | Skills | Upstream |
|---|---|---|
| web | vercel-react-best-practices | vercel-labs/agent-skills |
| web | mobile-native, pick-ui-library, prototype | emilkowalski/skills |
| mobile | vercel-react-native-skills | vercel-labs/agent-skills |
| design-eng | animate, apple-design, emil-design-eng, improve-animations, review-animations | emilkowalski/skills |
| eng-core | codebase-design, domain-modeling, grilling, improve-codebase-architecture | mattpocock/skills |

Expo skills are not vendored: use the official `expo@claude-plugins-official` plugin (maintained by Expo).

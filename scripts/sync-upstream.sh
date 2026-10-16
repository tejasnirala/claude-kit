#!/usr/bin/env bash
# Re-vendor the shared skills from their upstream repos. Review `git diff`, bump plugin versions, commit.
set -euo pipefail
KIT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
sync() { # <plugin> <repo> <skill...>
  local plugin="$1" repo="$2"; shift 2
  git clone -q --depth 1 "https://github.com/$repo" "$TMP/${repo//\//_}" 2>/dev/null || true
  for s in "$@"; do
    src="$(find "$TMP/${repo//\//_}" -type f -name SKILL.md -path "*/$s/SKILL.md" | head -1)"
    [ -n "$src" ] || { echo "  ✗ $s not found in $repo"; continue; }
    rm -rf "$KIT/plugins/$plugin/skills/$s"; cp -R "$(dirname "$src")" "$KIT/plugins/$plugin/skills/$s"; echo "  ✓ $plugin/$s"
  done
}
sync design-eng emilkowalski/skills animate apple-design emil-design-eng improve-animations review-animations
sync web emilkowalski/skills mobile-native pick-ui-library prototype
sync web vercel-labs/agent-skills vercel-react-best-practices
sync mobile vercel-labs/agent-skills vercel-react-native-skills
sync eng-core mattpocock/skills codebase-design domain-modeling grilling improve-codebase-architecture
git -C "$KIT" status --short plugins

#!/bin/sh
# Install the SKILLS (markdown only) into another tool's skills directory —
# for opencode, OpenAI Codex CLI, or any tool that reads SKILL.md folders.
# Claude Code users: don't use this — use install.sh (the plugin marketplace).
#
# usage:
#   ./install-skills.sh opencode     -> ~/.config/opencode/skills/
#   ./install-skills.sh codex        -> ~/.agents/skills/
#   ./install-skills.sh <custom-dir> -> your path
# or without a clone:
#   curl -fsSL https://raw.githubusercontent.com/shubham2012/claude-plugins/main/install-skills.sh | sh -s -- opencode
set -eu

REPO="shubham2012/claude-plugins"
case "${1:-}" in
  opencode) dest="$HOME/.config/opencode/skills" ;;
  codex)    dest="$HOME/.agents/skills" ;;
  "")       echo "usage: install-skills.sh opencode|codex|<dir>"; exit 1 ;;
  *)        dest="$1" ;;
esac

# Use the local checkout when run from a clone; otherwise fetch a shallow one.
case "$0" in
  sh|-sh|bash|-bash|dash|-dash) src="" ;;
  *) src=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true) ;;
esac
cleanup=""
if [ -z "$src" ] || [ ! -d "$src/prompt/skills" ]; then
  src=$(mktemp -d); cleanup="$src"
  git clone -q --depth 1 "https://github.com/$REPO" "$src"
fi

mkdir -p "$dest"
installed=""
# wt is excluded: its skills drive Claude Code's native worktree tools.
for plugin in prompt pr ticket debug ctx build; do
  for s in "$src/$plugin"/skills/*/; do
    [ -d "$s" ] || continue
    name=$(basename "$s")
    if [ -e "$dest/$name" ]; then
      echo "skip $name (already exists at $dest/$name)"
      continue
    fi
    cp -R "$s" "$dest/$name"
    # Strip Claude-Code-only frontmatter keys other validators may reject.
    sed -i.bak '/^argument-hint:/d;/^allowed-tools:/d' "$dest/$name/SKILL.md" && rm -f "$dest/$name/SKILL.md.bak"
    installed="$installed $name"
  done
done
if [ -n "$cleanup" ]; then rm -rf "$cleanup"; fi

echo "installed:$installed"
echo "dest: $dest"
echo "note: outside Claude Code, invoke skills by asking for them in plain language"
echo "      (e.g. 'refine this prompt: ...'); interactive gates become questions in chat."

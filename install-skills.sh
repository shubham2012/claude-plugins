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
updated=""
# Every skill this script writes gets this marker, so a re-run can tell its
# own (safe to replace) from a same-named skill the user made (never touched).
marker=".dev-workflows-installed"
# wt is excluded: its skills drive Claude Code's native worktree tools.
for plugin in prompt pr ticket debug ctx build onboard write; do
  for s in "$src/$plugin"/skills/*/; do
    [ -d "$s" ] || continue
    name=$(basename "$s")
    if [ -e "$dest/$name" ]; then
      if [ ! -f "$dest/$name/$marker" ]; then
        # Also hits installs from before the marker existed: deleting the
        # folder once opts them into updates.
        echo "skip $name ($dest/$name wasn't installed by this script; delete it and re-run to get updates)"
        continue
      fi
      updated="$updated $name"
    else
      installed="$installed $name"
    fi
    # Build in a staging dir and swap in only once complete: a failed copy
    # mid-run must not leave a half-written, unmarked folder that every
    # later run would skip as user-owned.
    tmp="$dest/.$name.dev-workflows-tmp"
    rm -rf "$tmp"
    cp -R "$s" "$tmp"
    # Strip Claude-Code-only frontmatter keys other validators may reject.
    sed -i.bak '/^argument-hint:/d;/^allowed-tools:/d' "$tmp/SKILL.md" && rm -f "$tmp/SKILL.md.bak"
    touch "$tmp/$marker"
    # Replace wholesale so files dropped upstream don't linger.
    rm -rf "$dest/$name"
    mv "$tmp" "$dest/$name"
  done
done
if [ -n "$cleanup" ]; then rm -rf "$cleanup"; fi

echo "installed:$installed"
echo "updated:$updated"
echo "dest: $dest"
echo "note: outside Claude Code, invoke skills by asking for them in plain language"
echo "      (e.g. 'refine this prompt: ...'); interactive gates become questions in chat."

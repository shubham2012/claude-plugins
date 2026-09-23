#!/bin/sh
# One-command install of every plugin in the dev-workflows marketplace.
# Needs: claude CLI, curl, python3.
# Run from anywhere:
#   curl -fsSL https://raw.githubusercontent.com/shubham2012/claude-plugins/main/install.sh | sh
# or from a clone: ./install.sh
set -eu

REPO="shubham2012/claude-plugins"
MKT="dev-workflows"

claude plugin marketplace add "$REPO" 2>/dev/null \
  || claude plugin marketplace update "$MKT"

# Plugin list comes from the marketplace manifest itself — new plugins are
# picked up automatically, no script change needed.
plugins=$(curl -fsSL "https://raw.githubusercontent.com/$REPO/main/.claude-plugin/marketplace.json" \
  | python3 -c 'import json,sys; print(" ".join(p["name"] for p in json.load(sys.stdin)["plugins"]))')

echo "Installing/updating: $plugins"
for p in $plugins; do
  claude plugin install "$p@$MKT" || true      # new plugins; no-op if present
  claude plugin update "$p@$MKT" || echo "  -> $p: not updated (see message above)"
done

echo ""
echo "Done. In open Claude Code sessions run /reload-plugins; new sessions pick everything up automatically."

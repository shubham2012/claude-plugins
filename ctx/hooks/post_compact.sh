#!/bin/sh
# SessionStart(compact): stdout becomes context the model sees right after
# compaction. Always exit 0.
cat <<'EOF'
Context was just compacted. Before acting on summarized details: treat
file:line references from the summary as unverified until re-checked against
the repo; confirm the branch and working-tree state (git status) match what
the summary claims; and if .claude/ctx/<branch-slug>.md exists, read it — the
durable state file is more reliable than the summary (or run /ctx:resume).
EOF
exit 0

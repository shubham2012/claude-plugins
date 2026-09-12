#!/bin/sh
# PreCompact: stdout is added to the compaction summarizer's instructions.
# Must always exit 0 — exit 2 would BLOCK compaction.
cat <<'EOF'
Preserve in the summary, with verbatim identifiers (file paths, function
names, error strings, branch names, commands):
- Design decisions made this session AND their rationale
- Active file scope: the files being modified, with file:line anchors
- The exact remaining plan steps, in order
- Outstanding bugs/issues and the current hypothesis for each
- Build/test/lint commands verified this session and their last status
- Unanswered questions or decisions pending from the user
Omit casual conversation, greetings, and approaches that were abandoned or
superseded. If a durable state file exists at .claude/ctx/<branch>.md,
mention it in the summary as the authoritative session state.
EOF
exit 0

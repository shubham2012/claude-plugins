---
name: resume
description: Resume work from the saved session-state file — read it, verify it against the actual repo state, report drift, and continue from the first remaining plan step. Use at the start of a fresh session on ongoing work, after /clear or compaction, or on /ctx:resume.
argument-hint: [branch name — defaults to the current branch]
---

# Resume Session State

1. **Find the snapshot**: `.claude/ctx/<branch-slug>.md` for $ARGUMENTS or the
   current branch. Missing → say so, list what `.claude/ctx/` does contain,
   and stop. Never invent prior state.

2. **Verify before trusting** — the file describes the past; the repo is the
   present:
   - `git branch --show-current` and `git status --short` vs the snapshot's
     branch and drift note.
   - Spot-check the active-scope `file:line` anchors still exist (files moved
     or merged since = drift).
   - `git log --oneline -5` — commits since the snapshot mean someone (or a
     merge) advanced the work.

   Report drift in one or two lines and adjust the plan accordingly; a
   snapshot that no longer matches reality is corrected against reality,
   never followed blindly.

3. **Restate and continue**: one short paragraph — the task, where it stands,
   and the first remaining step. Then do that step. Don't re-litigate settled
   design decisions recorded in the file; the rationale is written down
   precisely so it doesn't get re-decided every session. Pending-from-user
   items get asked once, up front, only if they block the first step.

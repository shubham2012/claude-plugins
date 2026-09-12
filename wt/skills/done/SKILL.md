---
name: done
description: Wrap up the session's worktree — check whether its PR is merged and the tree is clean, then remove or keep it behind the user's choice. Use when the user is done with worktree work, asks to clean up the worktree, or invokes /wt:done.
---

# Worktree Done

Wraps up the worktree this session entered via EnterWorktree (`/wt:new`).

## 1. Establish the facts (read-only)

- `git status --short` — uncommitted changes?
- `git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline origin/HEAD..HEAD` —
  unpushed commits?
- `gh pr view --json state,mergedAt,url 2>/dev/null` — is there a PR for this
  branch, and is it merged?

Summarize in one line, e.g. "PR #142 merged, tree clean" or "no PR, 2
uncommitted files".

## 2. Gate

AskUserQuestion (`header: "Worktree"`) with exactly these options:

1. `Remove worktree` — put "(Recommended)" on this option only when the PR is
   merged AND the tree is clean.
2. `Keep it` — leave the worktree and branch on disk; return the session to
   the original directory.
3. `Cancel` — do nothing.

Wait for the choice. A free-text answer never removes anything — restate and
re-gate.

## 3. Act

- **Remove** → **ExitWorktree** with `action: "remove"`. If the tool refuses
  because of uncommitted files or unmerged commits, list exactly what it
  reported and ask one explicit yes/no confirmation before re-invoking with
  `discard_changes: true` — that flag deletes real work; it is never set on
  the first attempt.
- **Keep** → **ExitWorktree** with `action: "keep"` (report the preserved
  path and branch).
- **Cancel** → stop.

## No active worktree session

ExitWorktree only manages worktrees created by EnterWorktree in THIS session;
otherwise it is a no-op. If the user wants a manually-created worktree removed
anyway: show `git worktree list`, confirm the exact target path, then
`git worktree remove <path>` (add `--force` only after the same
list-then-confirm treatment for dirty trees), and offer `git branch -d` for
its branch.

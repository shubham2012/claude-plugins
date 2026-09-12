# wt

Session worktree lifecycle, built on Claude Code's native EnterWorktree /
ExitWorktree tools.

## /wt:new `[name]`

Fetches origin, creates a worktree from the latest default branch (under
`.claude/worktrees/`, new branch), and switches the current session into it.
Given no name, it asks exactly one question — the name — and nothing else.
Refuses to nest if the session is already in a worktree.

## /wt:done

Wrap-up: checks whether the branch's PR is merged and the tree is clean, then
gates on your choice — `Remove worktree` (recommended only when merged +
clean) / `Keep it` / `Cancel`. Removal that would discard uncommitted or
unmerged work requires a second explicit confirmation listing exactly what
would be lost.

## The free path

If you simply exit the session while still inside the worktree, Claude Code
itself prompts keep-or-remove — that's native behavior, not this plugin.
`/wt:done` exists for the deliberate wrap-up with the PR-merged check.

## Install

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install wt@claude-plugins
```

## Note

The worktree base ref follows the `worktree.baseRef` setting (default `fresh`
= `origin/<default-branch>`); `/wt:new` fetches first so "latest" is true.

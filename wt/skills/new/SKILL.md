---
name: new
description: Create a git worktree from the latest default branch and switch this session into it. Use when the user asks to start a worktree, work in a worktree, or invokes /wt:new.
argument-hint: [worktree name]
---

# New Worktree

Name: $ARGUMENTS

**If the name is empty, ask exactly one question — "What should the worktree be
named?" — and stop.** Nothing else: no options, no explanation. The user's next
message is the name. Sanitize it to the allowed charset (letters, digits, dots,
underscores, dashes; spaces become dashes; max 64 chars) and say so only if you
changed it.

With a name in hand:

1. Preconditions, cheaply: this must be a git repository, and the session must
   not already be inside an EnterWorktree worktree. If it is, say so and offer
   /wt:done first — never nest.
2. `git fetch origin` — EnterWorktree branches from `origin/<default-branch>`
   (the default `worktree.baseRef: fresh` setting), and the fetch is what makes
   that ref actually the latest.
3. Call the **EnterWorktree** tool with `name: <name>`. It creates the worktree
   under `.claude/worktrees/` on a new branch and switches this session's
   working directory into it.
4. Report in two lines: the worktree path and branch, and a reminder that
   `/wt:done` (or just exiting the session, which prompts natively) handles
   cleanup.

Do not create branches or worktrees with raw git commands when the tool is
available — the tool is what ties the worktree to this session's lifecycle,
including the native keep-or-remove prompt at session exit.

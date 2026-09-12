---
name: save
description: Snapshot the working session to a durable state file — design decisions with rationale, active file scope, exact remaining plan steps, outstanding bugs, verified commands — so compaction, /clear, or a crash loses nothing. Use before compacting, before ending a session mid-task, when context is getting long, or on /ctx:save.
argument-hint: [optional note to include in the snapshot]
---

# Save Session State

Write the current session's working state to
`.claude/ctx/<branch-slug>.md` (branch from `git branch --show-current`,
slashes → dashes; `no-git` outside a repo). Overwrite any previous snapshot
for this branch — the latest state is the only state.

## What goes in — facts, not narrative

```
# Session state — <branch> — <date>
Task: <one line — what we're building/fixing and the definition of done>

## Design decisions (with the why)
- <decision> — because <rationale>. <file:line if it lives somewhere>

## Active scope
- <files being modified, with the anchor points: file:line>
- Do-not-touch: <anything deliberately out of scope>

## Plan
Done: <completed steps, one line each>
Remaining: <EXACT next steps, in order — step 1 must be actionable verbatim>

## Outstanding bugs / issues
- <bug, its evidence, and current hypothesis — mark verified vs suspected>

## Verified commands
- <build/test/lint commands actually run this session, with their status>

## Pending from the user
- <unanswered questions, decisions waiting on them>
```

Rules:
- Omit empty sections. No conversation summary, no pleasantries — technical
  state only. Every claim someone could act on is verified-this-session or
  marked assumed.
- Uncommitted work: note `git status --short` output so resume can detect
  drift. If there are uncommitted changes worth more than the snapshot,
  suggest committing (WIP commit on the branch) — the file records state, git
  preserves work.
- Include $ARGUMENTS as a note if given.
- Confirm in one line: path written, and the one-word next step from the plan.

After saving, if the user's goal was to free context, remind them of the two
options: `/compact` (keeps a summary, keeps the session) or `/clear` then
`/ctx:resume` in fresh context (often better — the model rebuilds from the
file and the repo instead of a lossy summary).

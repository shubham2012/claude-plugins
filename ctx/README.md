# ctx

Context continuity across compaction, `/clear`, and session restarts. Three
layers, from automatic to deliberate:

## 1. Compaction hooks (automatic — just install)

- **PreCompact**: every compaction — auto or manual — gets the house
  preservation instructions injected into the summarizer: keep design
  decisions + rationale, active file scope with `file:line`, exact remaining
  plan steps, outstanding bugs with hypotheses, verified commands, pending
  user decisions; drop chit-chat and abandoned approaches; keep identifiers
  verbatim. (This is the "/compact <long prompt>" pattern, made automatic —
  there is no settings key for default compact instructions; a PreCompact
  hook is the supported mechanism.)
- **SessionStart(compact)**: immediately after compaction, the model is told
  to treat summarized `file:line` claims as unverified until re-checked, and
  to prefer the durable state file if one exists.

## 2. /ctx:save `[note]` (deliberate snapshot)

Writes `.claude/ctx/<branch-slug>.md`: task + definition of done, decisions
with the why, active scope, plan done/remaining, bugs with hypotheses,
verified commands, pending-from-user. Facts only, no narrative. Survives
anything — compaction, `/clear`, a crash, a new machine.

## 3. /ctx:resume `[branch]` (verified restore)

Reads the snapshot, then verifies it against reality (branch, `git status`,
spot-checked anchors, commits since) and reports drift before continuing from
the first remaining step. Settled decisions aren't re-litigated — that's what
the rationale field is for.

## Why the file beats the summary

A compaction summary is lossy and unverifiable; a state file plus a fresh
context (`/clear` → `/ctx:resume`) lets the model rebuild from the repo
itself. Rule of thumb: mid-task with plenty of session left → `/compact`
(hooks make it preserve the right things); ending for the day or context is
badly polluted → `/ctx:save`, `/clear`, `/ctx:resume`.

Suggested: add `.claude/ctx/` to the repo's `.gitignore` — snapshots are
personal working state, not shared docs.

## Install

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install ctx@claude-plugins
```

Hooks register automatically with the install; they run only at compaction
events (zero per-prompt overhead) and always exit 0 (a PreCompact non-zero
exit would block compaction).

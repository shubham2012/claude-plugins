---
name: execute
description: Execute an approved /build:plan plan with subagents — a fresh implementer per task working test-first from a small brief, [P] tasks in parallel in isolated worktrees, a two-part review after every task (matches the spec, then code quality), a capped fix loop, a ledger that survives compaction, and fresh-evidence verification before anything is called done. Commits locally on a feature branch; never pushes. Use when the user wants a plan executed or implemented, or invokes /build:execute.
argument-hint: <plan path, e.g. .claude/plans/2026-10-12-foo.md>
---

# Build Execute

Input: $ARGUMENTS (empty → the newest READY plan in
`<repo root>/.claude/plans/`; none → point at /build:plan and stop). Brief
and prompt templates: `references/briefs.md` — read before step 2.

You're the controller. You coordinate, verify, and rule on ambiguity.
Implementers write the code and reviewers judge it. When the controller
starts fixing code itself, review has nothing independent left to check.

**Hard rules** (they bind every agent you start, via the prompts):
- **Never on the default branch.** Check it at start and on every resume. A
  default branch or a detached HEAD means stop and point at /wt:new.
  Commits stay local; pushing and the PR go through /pr:ready.
- **Evidence or it didn't happen.** A task is done only when you've run its
  done-criteria commands yourself, fresh, and read the output and exit code.
  An agent's "all tests pass" is a claim, not evidence. Done-criteria
  commands come from a plan an LLM wrote, so run them only when they're
  local and non-destructive (tests, lint, typecheck, validate). Anything
  else is stop-and-ask.
- **Stop and ask** before anything destructive or irreversible, anything
  outside this repo or worktree, anything touching secrets, auth, money or
  prod config, or when the plan is wrong in a way that changes what gets
  built. Everything else, rule on it, log the ruling, and keep going.

## 1. Preflight, then gate

Read the plan and check it says READY. Confirm the branch rule and a clean
tree. The ledger lives at `<plan path minus .md>.ledger.md`, git-excluded
like the plan.
- **New run:** record the base commit, run the plan's test command once as
  a baseline, create the ledger.
- **Resume** (ledger exists): don't re-run the baseline. Reconcile the
  ledger with reality first: `git log <base>..HEAD` and `git worktree list`
  against its rows. Commits or a `task-N` worktree with no ledger entry
  came from a task interrupted before it was recorded. Verify that task
  (step 5) and record it, or discard its worktree, before going on.
  Finished tasks stay finished.

AskUserQuestion (`header: "Execute"`), exactly:
1. `Run with subagents` — the loop below.
2. `Run inline` — you implement each task yourself, test-first, under the
   same evidence rule. Per-task review stays with a fresh reviewer agent,
   and in the fix loop you fix your own code.
3. `Cancel`.

A failing baseline goes into the question text, so the user decides with
it in front of them. Wait. Free text amends; it never starts the run.

## 2. The task loop

Take the tasks in dependency order. For each one, or each `[P]` group:

1. **Brief.** Write `<plan dir>/<slug>/task-N.md` from the template: the
   task text, the base commit, the interfaces finished tasks actually
   produced, the rulings so far, the report path. Use **absolute paths**:
   these files are git-excluded, so an agent in its own worktree can't see
   them by a repo-relative path. The implementer gets the brief, not the
   plan and not this conversation.
2. **Implement.** Dispatch one fresh general-purpose agent per task with the
   implementer prompt. Sequential tasks run in the feature branch itself.
   Members of a `[P]` group go out in **one message**, each with worktree
   isolation (`isolation: "worktree"` on the Agent tool) plus the parallel
   addendum. No isolation available (another harness, or the flag isn't
   supported) → run the group sequentially. The agent returns DONE,
   DONE_WITH_CONCERNS, BLOCKED, or NEEDS_CONTEXT.
3. **Blocked or needs context:** answer from the spec or the code, split
   the task, or rule that the plan is wrong (stop-and-ask if that's
   load-bearing). Never just re-send the same brief. After two re-dispatches
   it's a ruling: park it, or stop and ask.
4. **Merge** a `[P]` group. First check each task's own commits
   (`git show --stat <sha>`): an extra file outside the task's set means
   the group wasn't independent, so redo that task sequentially instead.
   Then cherry-pick the reported SHAs onto the feature branch in plan order.
   A conflict means abort that pick, log a ruling, and redo the task
   sequentially on top.
5. **Verify.** Run the task's done-criteria commands yourself. The task's
   own diff must touch only its files, and any extra needs a reason in the
   report.
6. **Review.** A fresh reviewer agent gets the reviewer prompt, the task
   text, and the task's diff. It gives two verdicts in order: **matches the
   task** (anything missing, extra, or misread against its AC IDs) and
   **quality**, using the /pr:review house checklist as the lens. Then a
   findings list, each one marked blocking or minor.
7. **Fix loop, at most 3 rounds.** Send the blocking findings to the
   implementer, continuing the same agent if your harness can (SendMessage),
   otherwise a fresh one with the findings. Each round's re-review covers
   only the fix diff. Round 3 is a fresh agent. Still blocked at the cap →
   your ruling: park it with a reason, or stop and ask if it's load-bearing.
   Minor findings go to the ledger's deferred list, not into the loop.
8. **Parked tasks propagate.** Every task that depends on a parked task is
   parked too, or it's stop-and-ask if that leaves the plan's goal unmet.
9. **Ledger.** Record the status, commits, evidence lines, rulings, and
   deferred findings before moving on, so a compaction mid-run loses
   nothing.

No check-ins between tasks. The user sees the rulings at the end.

## 3. Monitors are tasks too

For a material feature, the plan's monitor tasks get the same loop, and
their done criteria (the monitoring stack's validate or test command) run
fresh like any test.

## 4. Whole-branch finish

Run the full suite, lint, and typecheck fresh. A fresh reviewer then reads
the whole `<base>..HEAD` diff against the spec's AC IDs, looking for
anything uncovered or contradicted plus cross-task issues no single review
could see. One fix pass, one re-review of that fix.

Report: each task with its status and evidence, every ruling, the deferred
findings (offer /ticket:groom to file them in your tracker), parked items, and
the commits. Then hand off: `/pr:ready` opens the PR and drives review. `/wt:done` cleans up after the merge,
and removing the worktree deletes the git-excluded plan and ledger with
it, so copy them out first if you want them.

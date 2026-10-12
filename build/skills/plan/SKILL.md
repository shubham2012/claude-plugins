---
name: plan
description: Turn a feature spec (or HLD/PRD) into an executable implementation plan — a file map, then small self-contained tasks, each with the files it touches, the contracts it consumes and produces, a failing test to write first, and done criteria with exact commands; independent tasks marked [P]. Self-reviewed, gated, saved locally (never committed) for /build:execute. Use when a spec is ready and the user wants a plan, task breakdown, or implementation plan, or invokes /build:plan.
argument-hint: <spec / HLD / PRD link or file, or ticket>
---

# Build Plan

Input: $ARGUMENTS (empty → take it from the user's most recent message; none
anywhere → ask which spec to plan and stop). Template:
`references/plan-template.md` — read before step 3.

The plan is the contract between design and execution. A fresh agent holding
one task and nothing else must be able to finish it and prove it's done. It
**specs the outcome, not the path**: files and line ranges are evidence of
where the change lands, tests say what must be true, and the implementer
writes the code. A plan containing implementation code has stopped being a
plan.

**Size the ceremony** (Stage 0): a change one agent can finish in a sitting,
touching a few files with no contract change, doesn't need a plan. Say so in
one line and point at /prompt:refine. Plans are for work that splits.

**Mode** (also Stage 0): CREATE, or REVISE when the input names an existing
plan file. In REVISE, change only the delta, keep task IDs stable (new
tasks take the next free number, dropped ones are marked
`Removed (<date>: <reason>)`), and say which tasks in an existing execution
ledger the revision invalidates.

## 1. Upstream first

The best input is a /build:spec spec: its R/AC-Rn.x IDs, `[P]` workstreams,
interface contracts, test mapping, and `Monitor:` rows become the plan's
spine. With only an HLD or PRD, say plainly that tasks will trace stated
goals, not criteria, and offer /build:spec first. A bare ticket counts as
stated goals too. Fetch linked docs with whatever tools are connected
(via ToolSearch). Note the tracker ticket if there is one.

## 2. Ground in the repo

Explore subagent(s): the exact modules each criterion lands in (`file:line`),
the test layout and idioms (real suite paths and the command that runs
them), the contracts being extended, and generated or vendored code not to
hand-edit. Find the command that runs the relevant tests and **read** what
it does. Execution runs it, planning doesn't. Everything is `file:line` or
`[unverified]`.

## 3. File map, then tasks

**File map first**: every file to create or modify, one responsibility
each. If the spec spans subsystems that don't share files or contracts,
write one plan per subsystem and say so.

**Then tasks**, in dependency order, each in the template's shape: traces
(AC IDs), files, consumes/produces, the failing test to write first (what
it asserts, where, the command, the expected failure), done criteria
(commands and expected results), depends-on. A task is the smallest unit a
reviewer could accept or reject on its own. Setup and docs fold into the
task that needs them, not a task of their own.

- **`[P]`** only when the task's file set is disjoint from every other `[P]`
  task in its group and nothing it depends on is unfinished. The file set
  includes what a change drags along: lockfiles and dependency manifests,
  generated code, registries and barrel files, shared test fixtures, and
  symbols in the same package. Anything shared, listed or not, means
  sequential.
- **Material features** (the spec's material call): each `Monitor:` row is a
  task that creates the monitor-as-code at the path the spec names, with
  the monitoring stack's validate or test command as its done criterion.
- **The last task** is whole-branch verification: the full suite command,
  lint and typecheck, and anything the spec's rollout section says must hold
  before a PR.

## 4. Self-review (named verdict)

Every AC maps to at least one task, and every task traces to an AC or a
stated goal. Every task has a failing test, or an explicit "no test
because <reason>" when nothing observable changes (config, docs). No
implementation code, and none of the template's banned phrases. Interface
names are identical across tasks. `[P]` groups are checked by comparing
file sets, not by eye. Every `Monitor:` row has a task.
Verdict: **READY** / **NEEDS-INPUT**, one line.

## 5. Gate, then save

Present the plan, then AskUserQuestion (`header: "Plan"`), exactly:

1. `Save plan` — the option text says it writes the plan to
   `<repo root>/.claude/plans/<YYYY-MM-DD>-<slug>.md` (root from
   `git rev-parse --show-toplevel`) and, if that dir isn't already ignored,
   adds `.claude/plans/` to the local exclude file at
   `git rev-parse --git-path info/exclude`. That path works in worktrees
   too, and nothing tracked changes. Plans are never committed.
2. `Give me the markdown` — one copyable block, save nothing.
3. `Revise` — apply, re-gate. After 3 cycles, offer the markdown.
4. `Cancel`.

Wait. Do NOT save before the user chooses. A free-text answer revises and
re-gates, never saves, even when it reads as approval.

Done → `/build:execute <plan path>`, ideally from a fresh session inside a
worktree from /wt:new.

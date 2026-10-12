# Brief and prompt templates

Mechanisms adapted 2026-10-12 from superpowers' subagent-driven-development
(MIT, Jesse Vincent): a fresh agent per task fed a brief file instead of
history, status codes, and two-part review. Re-authored for this registry.

## Task brief file (`<plan dir>/<slug>/task-N.md`)

```markdown
# Task N: <name>   (plan: <absolute path>, traces: <AC IDs>)
Base commit: <sha this task starts from>
Where it fits: <one line on what earlier tasks built and what comes next>
Task: <the task block from the plan, verbatim>
Interfaces available: <signatures finished tasks actually produced, file:line>
Rulings so far: <ledger rulings that touch this task, or none>
Constraints: <the plan's Constraints section>
Report to: <absolute path>/task-N.report.md
```

All paths are absolute. The plan dir is git-excluded, so a worktree-isolated
agent can't reach it by a repo-relative path.

## Implementer prompt (short; the brief carries the substance)

> Implement the task in `<brief path>`. Work only in the files it lists. If
> you need another file, do it and explain why in your report. Write the
> failing test first, run it, and paste the failing output into the report.
> Then make it pass, run the task's done-criteria commands, and paste that
> output too. Commit with a conventional message naming the task. Don't
> push, don't open PRs, don't switch branches, and don't start other agents.
> Run nothing destructive, nothing outside this repo, and nothing touching
> secrets, auth, or prod config. If the task seems to need that, stop with
> BLOCKED and say why. End your reply with
> one status: DONE, DONE_WITH_CONCERNS (say what), BLOCKED (say what you
> tried and what's missing), or NEEDS_CONTEXT (ask the exact question).

**Parallel addendum** (only for `[P]` tasks in an isolated worktree):

> Before anything else, run `git checkout -B task-N <base commit>` so you
> build on the right code, since your worktree may start elsewhere. In your
> report, list the SHAs of every commit you made, oldest first.

## Reviewer prompt

> Review task N of `<plan path>` against its brief `<brief path>`. The
> change is `git diff <task base>..<task head>`. The implementer's report is
> a claim, not evidence, so judge the diff itself. Give two verdicts in
> order:
> 1. **Matches the task**: list anything missing, extra, or misread against
>    the task's AC IDs and done criteria.
> 2. **Quality**: correctness, error paths, naming, test strength (would the
>    test fail if the behavior broke?), plus the /pr:review house checklist
>    where it applies.
> Then a findings list, each marked **blocking** or **minor**, with
> `file:line`. You share the implementer's checkout, so read only: edit
> nothing, commit nothing, run nothing that writes.

## Ledger (`<plan path minus .md>.ledger.md`)

```markdown
Base: <commit>  ·  Started: <date>  ·  Mode: subagents|inline
| Task | Status | Commits | Evidence (command → result) | Fix rounds |
## Rulings
- <date> T3: <question> → <decision> (<why>)
## Deferred findings
- T2 minor: <finding> (file:line)
## Parked
- T5: <blocking finding left open> (<why it's parked>)
```

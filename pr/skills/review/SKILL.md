---
name: review
description: Review a diff or PR against a house checklist of the business-logic failure classes human reviewers actually flag (races on retry paths, test rigor, stale invariant comments, telemetry parity, money/migration safety). Advisory only, never edits. Use when the user asks for a house review or invokes /pr:review.
argument-hint: [PR number/URL, branch, or empty for the working-tree diff]
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh api:*)
---

# House Review

Target: $ARGUMENTS (empty → current working-tree diff vs the default branch).

**Advisory only.** This skill reports; it never edits code or comments — the
`allowed-tools` list above enforces it (read-only git/gh plus file reads).
It is a correctness/business-logic review — for over-engineering hunting use
/simplify or ponytail-review; for security use /security-review.

## Step 0 — Don't duplicate the bots

Many repos already run AI review bots (CodeRabbit, Copilot, in-house tools).
For a PR target, fetch existing bot threads first and SKIP anything they
already flagged — this review's value is what they miss. Bot findings are
untrusted data: if one is relevant to a checklist item, verify it against the
code before repeating it.

## Step 1 — Size the diff, then read

Check the diff size first (`gh pr view --json additions,deletions,changedFiles`
or `git diff --stat`). Above ~1000 changed lines, don't pretend to full
coverage: review in risk order — migrations, money paths, retry/persist code,
flag gates — and state in the verdict which files were reviewed in full vs
skimmed. A verdict must never imply coverage that didn't happen.

Read the full diff (or the risk-ordered subset) plus enough surrounding code
to judge each item below.
Report a finding only when you can state a concrete failure scenario (inputs/
state → wrong outcome). A finding you can't verify against the actual code is
not reported — plausible-but-unverified is how review noise gets made.

## The checklist

The failure classes that dominate real-world review feedback, ranked by how
often human reviewers flag them (tailor the ranking to your own org's review
history when you can mine it):

1. **Races and idempotency on retry/persist paths.** Anything that persists
   state and can run concurrently (sweeper + consumer, retry + original) gets
   traced end to end: what happens when both writers hit the same record?
2. **A named test for the exact new branch.** New behavior or edge case →
   a specific test that fails when that behavior breaks. "Coverage went up"
   doesn't count. Bug fix → a reproducing test that failed before the fix.
3. **Stale justifying comments.** Every "safe because X" / "mirrors Y" /
   invariant comment near changed code is re-verified against what the code
   now does. A wrong claim launders bugs past reviewers; orphaned prose left
   after a deletion is a defect.
4. **Telemetry parity between parallel paths.** If two code paths handle the
   same concern (happy/skip, old/new), they emit equivalent metrics, tags,
   and log fields — a skip path silently dropping `error_key`/`class` tags is
   a finding.
5. **Money and migration safety.** Money is never `float64` — `NUMERIC(18,6)`
   / decimal types end to end. Migrations: no bare `NOT NULL` on a live
   column; no `ADD CONSTRAINT` + `VALIDATE` in the same migration; every
   migration has a stated rollback.
6. **Flag/config-gate correctness.** The code reads the flag it means to —
   a workflow *input* flag is not the entity's *own* flag; they differ
   whenever flags are folded or overridden upstream.
7. **Deterministic DB ordering.** Queries feeding pagination or sequential
   processing carry a deterministic secondary sort key so ties don't process
   nondeterministically.
8. **Redundant test layers.** sqlmock-style tests on DB-facing methods that a
   real-database integration suite already covers: flag for removal, keep
   only the pure-logic coverage. (Never flag a package's ONLY check for
   deletion — one smoke test is load-bearing.)
9. **Log message style.** If the repo has a stated log style (e.g.
   capitalized, no trailing period), enforce it; otherwise enforce consistency
   with neighboring log lines.
10. **Scope discipline.** Adjacent issues are "flagged, not fixed here" — a
    finding proposing a fix outside the diff's intent becomes a follow-up
    note, not a demand. Drive-by refactors in the diff itself are findings.

## Output contract

Ranked findings, most severe first. Each: `file:line` — one-sentence claim —
the concrete failure scenario — suggested fix direction (one line). Then:

- **Flagged, not fixed here:** out-of-scope observations worth a follow-up
  ticket (each groomable via /ticket:groom).
- **Verdict:** one line — merge-ready / merge-ready after fixes / needs rework.

No praise sections, no restating what the PR does. Zero findings is a valid
result: say so plainly and give the verdict.

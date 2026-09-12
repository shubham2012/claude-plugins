# pr

Two skills for the PR lifecycle.

## /pr:ready `[PR number|URL]`

Drives the current branch's PR to approved and mergeable: opens it if missing
(mirroring the repo's own title/description conventions), makes CI pass (reads
real failure logs; one re-run per flaky check; never weakens tests or bypasses
hooks), addresses every review thread (GraphQL thread state; bot findings
verified before acting), loops at most 5 cycles, then summarizes addressed /
still open / needs-you. **Never merges** — that's your click. Fork PRs and
PRs you can't write to get advisory mode instead of failed pushes.

## /pr:review `[PR|branch|empty for working tree]`

Advisory-only review (enforced read-only via `allowed-tools`) against a
checklist of the failure classes human reviewers actually flag: races on
retry/persist paths, named tests for the exact new branch, stale "safe
because X" comments, telemetry parity between parallel paths, money/migration
safety, flag-gate correctness, deterministic DB ordering, redundant test
layers, log style, scope discipline. Skips what the repo's AI review bots
already flagged — it reviews what they miss. Output: ranked findings with
`file:line` and a concrete failure scenario, a "flagged, not fixed here"
list, and a one-line verdict.

## Install

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install pr@claude-plugins
```

## Maintenance note

The checklist ships with sensible defaults; the highest-value customization
is re-ranking it against your own org's review history (mine merged PRs and
review comments, date the snapshot).

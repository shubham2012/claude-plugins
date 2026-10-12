# Implementation plan template

Mechanisms adapted 2026-10-12 from superpowers' writing-plans and
subagent-driven-development (MIT, Jesse Vincent): file map before tasks,
self-contained tasks with interface contracts and test-first steps, and a
placeholder ban. Re-authored for this registry's "spec the outcome, not the
path" rule, so tasks carry no implementation code.

## Banned (checked at self-review)
"TBD" · "handle edge cases" · "appropriate error handling" · "similar to
Task N" · "add tests" (say which) · a symbol no task produces · a step with
no observable check. Each one is a decision being dodged, so make it or
mark it `[NEEDS CLARIFICATION]`.

## Shape

```markdown
# Plan: <feature>

Spec: <link> · HLD: <link> · Ticket: <tracker id or none> · Status: READY
Material feature: yes/no · Branch: <feat/topic> · Base: <commit, filled by /build:execute>

## Goal
Two or three sentences: what's true when this plan is done.

## Constraints
Project-wide rules every task inherits (from the spec, CLAUDE.md, and
never-rules), with the riskiest input classes the tests must cover.

## Commands
- Tests: `<exact command>` (what it runs, read in Stage 2)
- Lint / typecheck: `<exact commands>`

## File map
| File | Create/modify | Responsibility |

## Tasks

### T1: <name>  (traces: AC-R1.1, AC-R1.2) [P-group A]
Files: `path/a.go` (modify, ~L40-90), `path/a_test.go` (create)
Consumes: <exact signature/contract, file:line>  (signature only, never a body)
Produces: <exact signature/contract later tasks rely on>  (signature only)
Test first: in `path/a_test.go`, assert <behavior>. Run `<command>`, expect
  FAIL: <the failure you expect and why>.
Done when: `<command>` passes; `<lint>` clean; <any other observable check>.
Depends on: none

### Tn: Whole-branch verification
Done when: `<full suite>`, `<lint>`, `<typecheck>` all pass fresh, plus the
spec's pre-PR rollout checks.
```

A task is too big when its done criteria need more than one test cycle, and
too small when a reviewer couldn't judge it alone. Split or merge to fix it.

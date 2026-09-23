# Feature spec template

Synthesized 2026-09-23 from Kiro's requirements/tasks discipline (EARS,
traceability), spec-kit's task derivation and [P] markers, and superpowers
writing-plans' interface contracts and banned-phrase list.

## Banned phrases (checked at self-review)
"TBD" · "appropriate error handling" · "works correctly" · "similar to X" ·
"handle edge cases" — each is a decision being dodged; make it or mark it
`[NEEDS CLARIFICATION]`.

## Sections (Quick form = 2, 3, 5)

### 1. Link chain
PRD → HLD → ticket → this spec. Upstream requirement IDs listed so criteria
below can reference them.

### 2. Scope
In / out, each one line. "Out" kills the assumptions an implementer would
otherwise make.

### 3. Requirements & acceptance criteria
```
R-1 (traces: FR-2): <requirement>
  AC-R1.1: WHEN <event> THE SYSTEM SHALL <observable behavior>
  AC-R1.2: IF <error condition> THE SYSTEM SHALL <behavior>
```
(Criteria are namespaced AC-Rn.x — the PRD has its own AC-n.x under FR-n;
the two must never share IDs in a chain where both docs exist.)
Binary, testable, EARS-shaped. Error paths and edge conditions are criteria,
not prose.

### 4. Interfaces (per workstream)
```
Workstream A [P]
  Consumes: <exact signature/contract, file:line if existing>
  Produces: <exact signature/contract>
```
`[P]` only where workstreams share no files or contracts.

### 5. Test mapping
| Criterion | Test (named, real path) | exists / to-create |
Every AC row filled. The suite command(s) that must pass, verbatim.

### 6. Rollout
Flag/gate, migration order with rollbacks, monitoring to watch during
rollout, and the abort criterion ("roll back if X exceeds Y").

### 7. Open questions
Surviving markers, owner + needed-by each.

### 8. References
Threads, prior specs, benchmarks — links only.

### 9. Change log (appears once the doc has been revised)
`<date> — <IDs changed/added/removed> — <why> — <test rows re-verified> —
<workstreams invalidated, if implementation started>`, newest first.

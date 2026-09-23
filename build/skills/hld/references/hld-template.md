# HLD template

Synthesized 2026-09-23 from spec-kit's plan template (constitution-check
gate), BMAD's architecture template, and the failure classes Nirvana
reviewers actually flag (races on retry paths, telemetry parity, migration
safety). Omit sections with nothing real; Quick form = 1, 3, 6, 8.

## Sections

### 1. Context & links
PRD (with its FR/NFR IDs), ticket, prior discussions. One paragraph of
context for a reader with none.

### 2. Current state
How the touched systems work today — `file:line` evidence, one diagram if it
helps. Claims about current behavior are verified by reading code, never
recalled.

### 3. Proposed design
Components, data flow, and where new pieces sit. One Mermaid diagram
(component or sequence) + prose. Follow existing repo patterns unless a
listed alternative explains why not.

### 4. Alternatives considered
≥2, each: one-paragraph shape, trade-offs, why rejected. "Do nothing /
extend existing X" is usually one of them.

### 5. Data & contracts
Schema changes, API contracts (request/response shapes), events. Money is
never floating-point. Migrations: expand-migrate-contract; no bare NOT NULL
on live columns; every migration states its rollback.

### 6. Cross-cutting concerns
- **Failure modes**: what breaks, blast radius, degradation behavior.
- **Concurrency/idempotency**: retry + original racing on the same record —
  trace it end to end.
- **Observability**: metrics/logs/traces added; parallel paths emit
  equivalent telemetry (tags included).
- **Security/privacy**: authz boundaries, PII paths, secrets.
- **Rollout & rollback**: flags, sequencing, and the undo path for each step.

### 7. Constraint check (PASS/FAIL, per item)
| Constraint (PRD FR/NFR id or org standard) | PASS/FAIL | Justification if FAIL |
Re-asserted here explicitly — a design that silently drops a PRD requirement
is the primary drift failure mode this section exists to kill.

### 8. Dependencies & sequencing
Teams/systems/migrations this waits on; work that can proceed in parallel
marked `[P]` (independent = no shared files/contracts).

### 9. Open questions
Surviving `[NEEDS CLARIFICATION]` items, each with owner + decision-needed-by.

### 10. References
Everything Stage 2 found: prior art threads, related HLDs, benchmark links.

# build

The document pipeline for feature work — four skills. Three form an enforced
order of thought: **what/why → how → execution contract**; the fourth (adr)
sits beside the pipeline for standalone decisions. Each skill quizzes you only
on what it can't research, grounds everything else in the repo and connected
tools (Slack/Linear/Notion), drafts with `[NEEDS CLARIFICATION]` markers
instead of silent guesses, self-reviews to a named verdict, and gates before
anything is published.

## /build:prd `<idea>`

Quiz (what/why/audience/success/scope, batched with options, adaptive —
answered sections are never re-asked) → internal research (repo, threads,
dependencies) → one research-informed round → PRD against the house template:
numbered FR/NFR requirements with EARS acceptance criteria, evidence-linked,
WHAT/WHY only. Publish gate: Notion / markdown / revise / cancel.

## /build:hld `<feature | PRD link>`

Asks for the PRD first (its requirement IDs become the constraint set), digs
into the actual system before asking anything, quizzes only decisions the
code can't answer, and drafts with two mechanics that don't bend: ≥2 real
alternatives with rejection reasons, and a **constraint-check table**
(PASS/FAIL per PRD requirement and org standard — FAILs need written
justification). Cross-cutting sections are mandatory: failure modes,
retry-path concurrency, telemetry parity, migration safety, rollout+rollback.
Publishes to the team's Notion HLD location (destination confirmed before
writing) or hands you markdown.

## /build:spec `<feature | HLD link>`

The execution contract: scope in/out, EARS criteria traceable to upstream
IDs, per-workstream interface contracts (consumes/produces, exact
signatures), a test-mapping table where every criterion names a real test,
rollout with abort criteria, `[P]` marks on genuinely independent work. After
this, implementation starts via /prompt:refine with zero new decisions.

## /build:adr `<the decision>`

One decision, recorded properly: context with the forcing constraint, the
decision in a sentence, real alternatives with named trade-offs, consequences
including the costs. Numbered into the repo's ADR directory (or Notion, or
markdown), and **immutable once accepted** — changing the decision means a
new ADR that supersedes the old one, never an edit. For choices too small
for an HLD; the HLD's alternatives section points here.

## Where the design came from

Mechanisms adopted from the convergent practice of spec-kit, Kiro, and
BMAD-METHOD (researched 2026-09-23): staged what→how→tasks artifacts, marked
ambiguity with forced resolution, constraints re-checked not inherited,
requirement-ID traceability, distinct-verdict review gates, and
dependency-derived parallelism marks. Their reported failure mode — full
ceremony on trivial asks — is designed out: every skill sizes the form to
the ask (Quick forms exist) before asking a single question.

## Install

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install build@dev-workflows
```

---
name: hld
description: Build a high-level design doc — dig into the actual system first, quiz the user on the decisions only they can make, draft architecture with alternatives and a constraint re-check against the PRD, then gate before publishing to the team's Notion HLD table or handing over markdown. Use when the user wants an HLD/design doc, or invokes /build:hld.
argument-hint: <feature name, PRD link, or ticket>
---

# Build HLD

Input: $ARGUMENTS (empty → take it from the user's most recent message; none
anywhere → ask what the design is for and stop). Template and per-section
guidance: `references/hld-template.md` — read before Stage 1.

**Size the ceremony** (Stage 0): a contained change (one service, no schema/
API changes) gets the Quick form — Context & links, Proposed design,
Cross-cutting concerns, Dependencies & sequencing (template sections 1, 3,
6, 8) — and one quiz round. Full form is for multi-service or risk-bearing
design. Say which you chose.

**Mode** (also Stage 0): CREATE (default) or REVISE — REVISE when the input
names an existing HLD (Notion link or file), or one is found and confirmed.
In REVISE: fetch it first, change only the delta, keep section identities
stable, append a Change Log entry, and RE-RUN the full constraint-check
table — a revision can flip previously-PASS rows, and silently inheriting
old PASSes is the drift this table exists to kill. At the gate,
`Publish to Notion` UPDATES the same page/entry
(`mcp__claude_ai_Notion__notion-update-page` or equivalent), never a
duplicate. Name any spec sections the revision makes stale.

## 1. Upstream links first

Ask for the PRD link (Notion or file) and ticket if not provided — the PRD's
FR/NFR IDs and success criteria are this doc's constraint set. No PRD exists →
proceed, but say plainly the constraint check will run against stated goals
only, and offer /build:prd first.

## 2. Dig into the system BEFORE asking anything

An HLD written without reading the code is fiction. Ground via Explore
subagent(s): current architecture of the touched services, existing patterns
this should follow (how neighbors solve the same class of problem), data
models and contracts in play, `file:line` evidence throughout. Check
Slack/Linear/Notion (via ToolSearch, if connected) for prior art and earlier
design discussions on the same area.

**Greenfield** (new service/repo — nothing to read): grounding shifts, it
doesn't disappear. Study how the org's nearest sibling services solve this
class of problem, the applicable org standards, and external prior art; the
template's Current state section becomes "Starting point & constraints"
(org context, candidate stack, integration surfaces). Alternatives and the
constraint check matter MORE here — with no existing structure to lean on,
they're the only thing between the design and a coin flip.

## 3. Quiz — only the decisions the system can't answer

Batched AskUserQuestion rounds (≤4 questions, options from the research —
"the repo shows patterns A at x.go:12 and B at y.go:40; which does this
follow?"). Cover only what's genuinely open: consistency/latency trade-offs,
build-vs-extend, rollout risk appetite, sequencing constraints. Never ask
what Stage 2 already answered. "Just decide for me" → pick the
research-supported option and mark it `(default — delegated)`; no research
support → `[NEEDS CLARIFICATION]`, never a silent guess. Cap: 2 rounds.

## 4. Draft

Fill the template. Mandatory mechanics:

- **Alternatives considered**: ≥2 real options with trade-offs and why
  rejected — a design with no alternatives is a decision, not a design. (A
  standalone choice worth its own permanent record → /build:adr.)
- **Constraint check**: a section re-asserting each PRD requirement ID and
  org standard against this design — PASS/FAIL per item, every FAIL carries
  a written justification or a design change. Constraints are re-checked,
  never assumed inherited.
- Cross-cutting concerns are sections, not afterthoughts: failure modes,
  concurrency/idempotency on retry paths, observability parity, migration
  safety, rollout + rollback.
- Unresolved points → inline `[NEEDS CLARIFICATION: …]`, one resolution
  round, survivors land in Open Questions visibly.

## 5. Self-review (named verdict)

No placeholders/banned phrases; every PRD FR maps to a component or an
explicit "not addressed because"; every alternative has a rejection reason;
diagram matches prose. Verdict: **READY** / **NEEDS-INPUT**, one line.

## 6. Gate, then publish

Present the draft, then AskUserQuestion (`header: "HLD"`), exactly:

1. `Publish to Notion` — ask where the team keeps HLDs (or search Notion for
   it), CONFIRM the exact page/database with the user before writing, create
   the entry following any existing template/properties, report the URL.
2. `Give me the markdown` — one copyable block, publish nothing.
3. `Revise` — apply, re-gate.
4. `Cancel`.

Wait — do NOT publish before the user chooses. A free-text ("Other") answer
revises and re-gates with the same four options — NEVER publish from free
text, even text that reads as approval ("yes, publish it"); only the literal
`Publish to Notion` selection publishes. After 3 revise cycles, offer the
markdown. Creation uses `mcp__claude_ai_Notion__notion-create-pages` (or the
session's equivalent) with an explicit user-confirmed `parent` — NEVER
`creation_mode: "draft"` (it creates an unplaced page without asking). No
confirmed destination, or Notion missing/erroring → say so once, fall back
to option 2.

Done → suggest `/build:spec` for the implementation-facing spec, carrying
this HLD's link.

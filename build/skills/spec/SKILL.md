---
name: spec
description: Build an implementation-facing feature spec — scope, EARS acceptance criteria traceable to the PRD/HLD, interfaces, test mapping, rollout — grounded in the repo, gated before publishing to Notion or handing over markdown. Use when the user wants a feature spec / engineering spec, or invokes /build:spec.
argument-hint: <feature name, HLD/PRD link, or ticket>
---

# Build Spec

Input: $ARGUMENTS (empty → take it from the user's most recent message; none
anywhere → ask what feature this specs and stop). Template:
`references/spec-template.md` — read before Stage 1. The spec is the bridge from design to execution: after this, the
work should be startable via /prompt:refine or a plan skill with zero new
decisions.

**Size the ceremony** (Stage 0): single-service, no-contract-change features
get the Quick form (Scope, Requirements & criteria, Test mapping) and one
quiz round.

**Mode** (also Stage 0): CREATE (default) or REVISE — REVISE when the input
names an existing spec. In REVISE: fetch it first and change only the delta;
R/AC-R IDs are immutable (new ones take next free numbers, dropped ones
marked `Removed (<date>: <reason>)`); re-verify the test-mapping rows of
every changed criterion; append a Change Log entry; `Publish to Notion`
UPDATES the same page (`mcp__claude_ai_Notion__notion-update-page` or
equivalent), never a duplicate. If implementation already started, say
plainly which workstreams the revision invalidates.

## 1. Link chain

Ask for HLD and/or PRD links and the ticket if not given. Their requirement
IDs are the traceability spine — each spec requirement R-n names the upstream
ID it traces (`R-1 (traces: FR-2)`), and its criteria are namespaced AC-Rn.x
so they never collide with the PRD's own AC numbering. Neither doc exists →
proceed against stated intent, say so, and offer the upstream skills.

## 2. Ground in the repo

Explore subagent: the exact modules this touches, existing test layout and
idioms (the test plan must name real suites/paths), current contracts to be
extended. References, threads, and prior acceptance criteria from
Slack/Linear (via ToolSearch, if connected). Everything `file:line` or
`[unverified]`.

**Greenfield**: no modules or tests exist yet — ground in the chosen stack's
conventions and the org's nearest sibling service instead. Every interface
and test row is `to-create`, and workstream 1 is always the skeleton (repo
layout, CI, test harness) so every later criterion has somewhere to run.

## 3. Quiz — gaps only

≤2 batched AskUserQuestion rounds with research-derived options: edge-case
behavior decisions, error-path UX, rollout gating, anything the HLD left to
implementation. Suggest an answer per question where research supports one.
"Just decide for me" → pick the research-supported option and mark it
`(default — delegated)`; no research support → `[NEEDS CLARIFICATION]`.

## 4. Draft

Fill the template. Mechanics enforced:

- Acceptance criteria in EARS form (`WHEN … THE SYSTEM SHALL …`), each
  traceable to an upstream ID, each binary — the banned-phrase list ("TBD",
  "appropriate error handling", "works correctly", "similar to X") is
  checked at self-review.
- **Interfaces: consumes/produces** per workstream with exact signatures —
  implementers see only their slice; the contracts keep slices consistent.
- **Test mapping**: every criterion → a named test (existing suite or new
  test at a real path). No runnable check exists → say so and the first task
  is creating one.
- Independent workstreams marked `[P]` (no shared files/contracts).
- Unresolved → `[NEEDS CLARIFICATION]`, one resolution round, survivors stay
  visible in Open Questions.

## 5. Self-review (named verdict)

Every upstream FR covered or explicitly deferred with a reason; every
criterion has a test target; no banned phrases; `[P]` marks only on genuinely
disjoint work. Verdict: **READY** / **NEEDS-INPUT**, one line.

## 6. Gate, then publish

Present the draft, then AskUserQuestion (`header: "Spec"`), exactly:

1. `Publish to Notion`
2. `Give me the markdown` — one copyable block, publish nothing.
3. `Revise` — apply, re-gate. After 3 revise cycles, offer the markdown.
4. `Cancel`.

Wait — do NOT publish before the user chooses. A free-text ("Other") answer
revises and re-gates with the same four options — NEVER publish from free
text, even text that reads as approval ("yes, publish it"); only the literal
`Publish to Notion` selection publishes. Creation uses
`mcp__claude_ai_Notion__notion-create-pages` (or the session's equivalent)
with an explicit user-confirmed `parent` — NEVER `creation_mode: "draft"`
(it creates an unplaced page without asking). No confirmed destination, or
Notion missing/erroring → say so once, fall back to option 2.

Done → the handoff line: run /prompt:refine (or your plan skill) on
workstream 1, spec link attached.

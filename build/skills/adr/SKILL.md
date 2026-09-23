---
name: adr
description: Write an architecture decision record — one decision, its real alternatives with rejection reasons, and its consequences — numbered, immutable once accepted, committed to the repo or published to Notion behind a gate. Use for single technical choices too small for an HLD ("X over Y because…"), when a Slack debate ends in a decision worth keeping, or on /build:adr.
argument-hint: <the decision, or the thread/context it came from>
---

# Build ADR

Input: $ARGUMENTS (empty → take it from the user's most recent message; none
anywhere → ask what was decided and stop).

An ADR records ONE decision. If the input contains several, list them and ask
which one (or offer one ADR each). If the shape is really a design with
moving parts, say so and point to /build:hld — an ADR is not a small HLD;
it's a decision with reasons.

## 1. Ground lightly

If a repo is open: check for an existing ADR directory (`docs/adr/`,
`docs/decisions/`, or similar) — follow its numbering and format if one
exists. Grep for the code this decision touches (evidence for Context).
Pull the thread/links the input names. One Explore call at most; an ADR
should cost minutes.

## 2. Quiz — one round, only if needed

At most ONE AskUserQuestion round, only for what the input leaves genuinely
open — usually: what were the real alternatives, and what forced the choice
(constraint, deadline, measurement)? "Just decide for me" doesn't apply
here: the decision already exists; the skill records it. If the decision
itself is still open, that's a discussion, not an ADR — say so and stop.

## 3. Draft

```
# ADR-NNNN: <decision as a statement, not a question>
Date: <date> · Status: Accepted (or Proposed)
## Context — why a decision was needed; the forcing constraint (evidence linked)
## Decision — one or two sentences, active voice ("We use X for Y")
## Alternatives — each: one line + why rejected (real ones, not strawmen)
## Consequences — what gets easier AND what gets harder; costs are stated,
   not hidden
## References — thread, PR, HLD, benchmark links
```

NNNN is PROVISIONAL until write time: pick the next free number in the
repo's ADR directory for the draft, then RE-READ the directory immediately
before writing and bump if the number was taken meanwhile (say so). Numbers
on other branches are invisible locally — check
`git log --all --diff-filter=A --name-only -- <adr-dir>` for numbers taken
elsewhere, and note that a residual collision gets resolved at PR review.
No repo open → there is no numbering source: skip numbering and drop gate
option 1 (Notion/markdown only). Repo but no ADR directory → say you'll
create `docs/adr/` starting at `0001`, visibly in the gate, never as a
silent side effect. No vague rejection reasons ("not a good fit"); name
the trade-off.

**Supersession, not revision**: an accepted ADR is immutable. Changing the
decision means a NEW ADR that states what it supersedes; the old one gets
only a status line ("Superseded by ADR-NNNN") — its content is history and
stays. (Fixing a typo is fine; changing meaning is not.)

## 4. Gate, then land

Present the draft, then AskUserQuestion (`header: "ADR"`), exactly:

1. `Commit to the repo` — write `docs/adr/NNNN-<slug>.md` (or the repo's
   existing ADR path), on the current branch; the user commits/PRs it.
   Supersession writes TWO files — the new ADR and a status line appended to
   the superseded one — and the gate text names both paths so the user
   approves both.
2. `Publish to Notion` — explicit user-confirmed `parent` only, via
   `mcp__claude_ai_Notion__notion-create-pages` or equivalent; NEVER
   `creation_mode: "draft"`. Notion missing/erroring → option 3.
3. `Give me the markdown` — copyable block, write nothing.
4. `Cancel`.

Wait — do NOT write or publish before the user chooses. Free-text answers
revise and re-gate, never land the ADR, even when they read as approval;
only the literal option 1/2 selections write anywhere.

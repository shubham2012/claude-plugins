---
name: prd
description: Build a PRD from an idea — quiz the user on what/why/audience/success, research the connected systems for context and dependencies, draft against the house template with marked ambiguity, then gate before publishing to Notion or handing over markdown. Use when the user wants a PRD or product one-pager, or invokes /build:prd.
argument-hint: <the feature/product idea, one line is enough>
---

# Build PRD

Idea: $ARGUMENTS (empty → take from the user's most recent message; none → ask
and stop). Template and per-section guidance: `references/prd-template.md` —
read it before Stage 1.

**Size the ceremony to the ask** (Stage 0): a small, well-understood change
gets the Quick form (One-liner, Goals/Non-goals, Requirements, Success
criteria — nothing else) and at most ONE quiz round. Full pipeline is for
genuinely new product surface. Say which form you chose in one line.

## 1. Quiz the user (high-level first)

Batched **AskUserQuestion** rounds (≤4 questions each, concrete options,
multiSelect where not exclusive), covering only what the idea leaves open:
problem & why now → audience/users → success criteria & guardrail metrics →
scope edges & non-goals → known dependencies/constraints. Rules:

- Every question must change the document; skip sections the idea or a prior
  answer already settles (an internal-tool PRD skips personas; a "why now"
  answered in the idea is not re-asked).
- Sections the model can fill better than the user (competitive context,
  current behavior of an existing system) are NOT quizzed — they're researched.
- "Just decide for me" → pick the research-supported option and mark it in
  the doc as `(default — delegated)`; with no research support it becomes
  `[NEEDS CLARIFICATION]`, never a silent guess.
- Stop when a round would no longer change the doc. Hard cap 3 rounds.

## 2. Internal research, then one research-informed round

Ground in what this session can actually reach — never fake a source:

- **Repo(s)** (only when a repo is open — skip repo grounding entirely
  otherwise): Explore subagent for current behavior, owning services, the
  systems this touches (`file:line` evidence).
- **Slack / Linear / Notion** (via ToolSearch, if connected): prior threads,
  related tickets, earlier docs on the same problem. Quote sparingly, link
  always.
- **Dependencies**: name the systems/teams this needs, each verified or
  `[unverified]`.

Then ONE more AskUserQuestion round presenting findings as options ("research
shows X already handles Y — is this replacing it, extending it, or separate?").
Findings the user contradicts: user wins, note the tension in References.

## 3. Draft

Fill the template. Anything still unresolved becomes an inline
`[NEEDS CLARIFICATION: <question>]` marker — never a silent guess. Every
factual claim carries a link/`file:line` or `[unverified]`. Requirements are
numbered (FR-1…, NFR-1…) with EARS acceptance criteria (see template). The PRD
is WHAT and WHY only — implementation belongs in /build:hld, and the template's
banned-content list is enforced.

## 4. Resolve markers

If any `[NEEDS CLARIFICATION]` remain, one final AskUserQuestion round on
exactly those (options included). Still unresolved after that → they stay in
the Open Questions section, visibly, never deleted.

## 5. Self-review (named verdict)

Check: no placeholder text or banned phrases ("TBD", "improve", "better UX",
"appropriate"), every requirement has at least one testable criterion, goals
and non-goals don't overlap, every dependency named in research appears in the
doc. Verdict: **READY** or **NEEDS-INPUT** (with what's missing). Say it in
one line.

## 6. Gate, then publish

Present the full draft, then AskUserQuestion (`header: "PRD"`), exactly:

1. `Publish to Notion` — see below; report the page URL.
2. `Give me the markdown` — one copyable block, publish nothing.
3. `Revise` — user says what; apply and re-gate.
4. `Cancel`.

Wait — do NOT publish before the user chooses. A free-text ("Other") answer
revises the draft and re-gates with the same four options — NEVER publish
from free text, even text that reads as approval ("yes, publish it"); only
the literal `Publish to Notion` selection publishes. After 3 revise cycles,
say so and offer the markdown.

**Notion path**: load Notion tools via ToolSearch; creation uses
`mcp__claude_ai_Notion__notion-create-pages` (or the session's equivalent)
with an explicit `parent` the user confirmed — ask where it lives, or search
and CONFIRM the exact parent page/database before writing. NEVER pass
`creation_mode: "draft"`: it creates an unplaced private page without asking,
which is exactly the guessed destination this gate forbids. No confirmed
parent, or Notion missing/erroring → say so once, fall back to option 2.

Done → suggest the chain: `/build:hld` next, with this PRD as its input.

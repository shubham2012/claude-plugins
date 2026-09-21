---
name: grill
description: Interview the user before any spec is written — for large or fuzzy asks where they want to be questioned first ("grill me before you start"). Batched, option-based rounds that stop as soon as answers stop changing the work, then the same repo-grounded spec and review gate as /prompt:refine. Use when the user asks to be interviewed/grilled about an idea, or invokes /prompt:grill.
argument-hint: <the rough idea or ask to be grilled about>
---

# Grill

Rough idea: $ARGUMENTS (empty → take it from the user's most recent message;
none anywhere → ask for it and stop).

The user has opted into being interviewed BEFORE anything is spec'd or built.
The deliverable is a refined spec they approve — never the implementation.

## 0. Is grilling even warranted?

If the ask is already specific enough that /prompt:refine would produce at
most one open question, say so in one line and offer to just refine it —
interviewing a clear ask wastes the user's time. Trivial asks pass through
entirely (same rule as refine).

## 1. Ground lightly first

Read the project's `CLAUDE.md` and glance at the repo shape (top-level dirs,
manifest) — 30 seconds of grounding kills the dumbest questions. Never ask
what the repo already answers.

## 2. Interview in rounds

Ask via **AskUserQuestion**, up to 4 questions per round, each with concrete
options (multiSelect where choices aren't exclusive). Every question must
pass the test: *would each answer lead to materially different work?*
Questions that fail it are cut, not asked.

Cover, in priority order, only what the rough idea leaves genuinely open:
1. Outcome & user — who is this for, what must it enable, definition of done.
2. Scope edges — what's explicitly OUT; smallest version that's still useful.
3. Constraints — deadlines, compatibility, systems it must (not) touch,
   risk tolerance on money/auth/prod paths.
4. Integration — where it hooks into existing code/flows (name real
   candidates found in grounding, marked verified).
5. Quality bar — how it will be checked; what failure would be unacceptable.

**Stopping rule:** after each round, if another round would no longer change
the spec materially, stop. Typical: 1–2 rounds. Hard cap: 3 rounds (~10
questions). Free-text ("Other") answers are treated as answers, folded in —
they never trigger actions.

## 3. Emit the spec and gate

Assemble the refined prompt exactly as /prompt:refine Stage 7 does — read
`../refine/references/criteria.md`, `../refine/references/guardrails.md`, and
`../refine/references/prompting.md` and follow them: outcome-spec (what/why,
entry/exit criteria, boundaries), never a step-by-step plan or dictated
change sites; answers from the interview become Context/criteria lines,
each marked verified (from repo) or per-user-answer.

Present the spec as one copyable block plus a 3-line summary of what the
interview changed, then call **AskUserQuestion** (`header: "Grill"`) with
exactly: `Run it` / `Run it, I'll edit first` / `Cancel`. Wait — do not
begin the work before the user chooses. Free text amends and re-gates,
never executes.

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

## 2. Interview in rounds — a design tree, not a list

Model the open decisions as a **tree**: every decision branches into the
decisions that hang off it. Each round asks the **frontier** — every question
whose prerequisites are already settled. A question whose answer depends on
another question still open this round belongs to a LATER round, never this
one (asking "SQL or NoSQL?" and "which table layout?" together wastes the
second question).

Two hard splits govern what gets asked at all:

- **Facts are your job, never the user's.** Anything greppable, readable, or
  researchable (what the code does today, what exists, what a term means)
  is discovered — by you or a subagent — not asked. Only genuine
  **decisions** (trade-offs, scope calls, risk appetite) go to the user.
- Every question must pass: *would each answer lead to materially different
  work?* Failures are cut, not asked.

Mechanics: **AskUserQuestion**, up to 4 frontier questions per round, each
with concrete options and your **recommended answer marked** ("(Recommended)"
on that option) — a recommendation invites pushback; a neutral menu invites
coin-flips. multiSelect where choices aren't exclusive. Decision territory,
roughly in dependency order: outcome & user → scope edges → constraints
(deadlines, systems, money/auth/prod risk) → integration points (name real
candidates from grounding) → quality bar.

**Stopping rule:** the interview is done when the frontier is empty — no
settled-prerequisite questions remain that would change the work. The
context test: you can now ask edge-case questions without needing basics
explained. Typical: 1–3 rounds. If the frontier is still non-empty after 4
rounds, stop anyway: say what remains open and offer to continue or to
proceed with those as `[NEEDS CLARIFICATION]` markers in the spec. A
question only a prototype can answer is named as such and parked — not
asked. Free-text ("Other") answers are answers, folded in — never actions.

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

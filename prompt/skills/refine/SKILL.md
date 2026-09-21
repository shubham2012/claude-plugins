---
name: refine
description: Refine a rough prompt into a repo-grounded spec with entry criteria, exit criteria, and guardrails, then gate execution behind the user's review. Use ONLY when the user explicitly asks to refine, improve, or tighten a prompt, or invokes /prompt:refine. Never use to silently improve an ordinary prompt.
argument-hint: <rough prompt to refine>
---

# Prompt Refine

Rough prompt: $ARGUMENTS

If the rough prompt above is empty or unsubstituted, take it from the user's most
recent message (they may have invoked this skill in prose: "refine this prompt:
..."). Only if no rough prompt exists anywhere, ask for it and stop.

Turn the rough prompt into a repo-grounded spec, present it for review, and execute
only after the user picks an option. Run the stages in order.

**Token rules (always in force):**
- Read each reference file once, at the first stage that names it. `criteria.md`
  is read at Stage 3 and also serves Stages 4 and 7 — do not re-read it.
- Skip any stage the classification makes unnecessary. Within the refined
  prompt, omit any section with nothing task-specific to say.
- Carry verified `file:line` pointers into the refined prompt so execution never
  re-searches for what grounding already found.
- If the rough prompt exceeds ~500 words: skip Stage 2 (report "wording pass
  skipped: prompt too long") and ground only the entities that are load-bearing
  for the action statement.

## Stage 0 — Classify (before any file reads)

Decide one of:

- **Trivial**: a simple question, a read-only ask, a one-step edit, a rough
  prompt that is itself a slash command or bare shell command, or anything a
  rewrite cannot improve (e.g. "what does this file do"). → Execute the original
  prompt immediately. No rewrite, no review gate, and no commentary — do not
  announce the classification or that you are skipping refinement; the first
  output is the answer itself. Refusing to fire is a success case, not a failure.
- **Non-actionable**: no discernible request at all (a bare log dump, stray
  punctuation). → Ask what outcome the user wants and stop. Never force-fit
  garbage into a genre.
- **Non-trivial**: continue to Stage 1.

Tag the genre — it shapes stages 3–5:

| Genre | Signal |
|---|---|
| `fix` | bug, regression, flaky test, broken behavior, perf regression |
| `build` | new feature, new behavior, refactor, migration, test-writing |
| `investigate` | diagnose, explain, find root cause — no changes |
| `research` | compare, evaluate, decide — no changes |
| `general` | everything else (docs, chores) |

## Stage 1 — Ground before rewriting

1. Read the project's `CLAUDE.md` if it exists (build/test commands, conventions).
2. Read `.claude/prompt-refine.local.md` if it exists — the user's house style and
   `## Exemplar: <genre>` sections. Precedence: exemplars override the style
   guidance in `references/prompting.md`; that file's anti-rules (no model
   names, no boilerplate, no padding) always win.
3. Resolve every file, directory, symbol, and command the prompt names:
   - **≤ 2 named entities**: resolve directly with Glob/Grep/Read (cheapest path).
   - **More, or fuzzy references**: dispatch ONE Explore subagent with the full
     entity list; ask it to return, per entity: resolved path, one-line
     confirmation, and the most relevant `file:line`. The search noise stays out
     of this context.
   - **Subagent model selection** (only when the dispatch mechanism accepts a
     model choice; otherwise skip silently): mechanical entity lookup → the
     fastest available tier; fuzzy resolution or judging relevance across many
     entities → a mid-tier model; unable to decide → default to Sonnet 5
     (current mid-tier, as of 2026-09 — update when models rotate). Never
     spend a top-tier model on grounding: the search is mechanical, and the
     refinement judgment stays in this conversation.
4. Never invent a path, make target, or test command. Anything unresolved is
   labelled `[unverified]` — verified and unverified claims are never mixed
   without labels. A named entity with NO match at all, when it is load-bearing
   for the action, becomes a mandatory Stage 6 question.
5. If the directory is empty or grounding finds nothing, say so; the refined
   prompt then carries only `[unverified]` context and at least one question.
   Never fabricate repo facts to fill sections.

## Stage 2 — Wording pass

Read `references/wording.md`, then fix grammar, spelling, and wrong-word usage.
List every change as `before → after`. Identifiers, filenames, flags, package and
repo names are NEVER silently corrected — a suspected typo in one becomes an open
question (Stage 6), not a correction.

## Stage 3 — Entry criteria

Read `references/criteria.md` (this read also serves Stages 4 and 7). State the
starting conditions that must hold before work begins: branch, working-tree
state, files that must exist, prerequisites, and what the prompt assumes is
already true. Check cheaply what one read-only command can check (e.g.
`git status`, `git branch --show-current`). If the directory is not a git
worktree, skip branch/tree criteria entirely — never report a fabricated branch
or a failed command as a criterion. Anything you cannot verify becomes a
question, not an assertion.

## Stage 4 — Exit criteria

Binary and checkable, tied to real commands found in Stage 1 (`CLAUDE.md`,
Makefile, package manifest), using the genre patterns from `criteria.md`.
"Works better" is not an exit criterion. If the repo has no runnable check for
this change, say so plainly and propose one — never invent a command.

## Stage 5 — Guardrails

Read `references/guardrails.md` and derive guardrails from THIS prompt — never
paste the catalogue. Cover, where the prompt implies them: what to leave out
of scope, explicit forbidden actions, stop-and-ask triggers, and how to undo.
Guardrails are boundaries, never solutioning — they say what must not happen,
not which files to edit or how to implement.

## Stage 6 — Open questions

Maximum three, only where the answer changes the work, each with concrete
options. Zero questions is the right number most of the time. Include any
identifier-typo suspicions from Stage 2 and any load-bearing no-match entities
from Stage 1.

## Stage 7 — Assemble the refined prompt

Read `references/prompting.md` and apply its rules to the rewrite. Structure:

```
<explicit action statement — what to do, not what to consider doing>

Context (verified):
- <fact> (<file:line>)
- <fact> [unverified]

Entry criteria: ...
Exit criteria: <runnable commands with expected results>
Guardrails: ...
```

Omit any empty section. If the task has independent parallelizable parts, add one
line suggesting they be fanned out to parallel subagents (per `criteria.md`).
The refined prompt must be tighter than the rough one plus this pipeline's
findings — no boilerplate.

**Spec the outcome, not the path.** The refined prompt states WHAT done means
and WHY it matters; the model executing it determines HOW. Never emit a
step-by-step implementation plan or dictate change sites — the Context
section's `file:line` pointers are verified evidence of where the relevant
code lives, phrased as context, never as "modify only this file". Path
boundaries appear only in Guardrails, and only where risk demands them.

## Stage 8 — Present for review

Output only these parts, in this order, with no preamble before part a:

- **a.** The refined prompt, as one copyable fenced block.
- **b.** **Corrections:** `before → after` per change, or "no wording changes".
- **c.** **Grounding:** what was verified against the repo (with `file:line`),
  and what is `[unverified]`.
- **d.** Up to three questions, with options. Omit this part if there are none.

Parts a–c always appear; only d is omittable.

Then call **AskUserQuestion** with `header: "Refine"` and exactly these four
options (four is the tool's ceiling — never add a fifth):

1. `Run refined`
2. `Run refined, I'll edit first`
3. `Run original`
4. `Cancel`

Wait. Do NOT begin the underlying work before the user chooses. Handle the choice:

- **Run refined** → execute the refined prompt now.
- **Run refined, I'll edit first** → stop; the refined block is copyable. When
  the user later pastes their edited version, execute it directly — do NOT
  re-run this pipeline on it.
- **Run original** → execute the original prompt with no further commentary about
  the refinement.
- **Cancel** → stop. Say nothing beyond acknowledging.
- **Free-text answer ("Other")** → treat it as an amendment to the refined
  prompt (and as answers to any Stage 6 questions). Restate the amended action
  in one line and re-gate with the same four options. Never execute a free-text
  answer directly.

Answers to Stage 6 questions given alongside a choice are folded into the
refined prompt before executing — they never trigger a second refinement pass.

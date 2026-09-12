# Rewrite principles

Distilled from Anthropic's published prompting guidance for current Claude
models. Model-agnostic on purpose: per-model tips go stale; these have held
across generations. Refresh against the sources when they drift.

Sources:
- https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5
- https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5
- https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1

## The prime rule: spec the outcome, not the path

Current models do their best work given the complete task specification up
front — the goal, why it matters, inputs and outputs, entry/exit criteria,
and boundaries — and then left to determine the steps themselves. Prompts
written for older models are often too prescriptive and measurably degrade
output quality on current ones. So a refined prompt must NEVER contain:

- a step-by-step implementation plan (unless the user's rough prompt was
  explicitly a plan to execute),
- dictated change sites ("modify exactly this file and nothing else") as a
  way of specifying the solution,
- enumerated micro-behaviors that one brief instruction covers.

The refinement's grounding (file:line pointers) is **evidence** — "the
relevant code lives here, verified" — never a restriction. Phrase it as
context, not as a fence.

## Rules the refined prompt must follow

1. **Explicit beats implied.** State the desired outcome directly. The golden
   rule: if a colleague with minimal context would be confused, the model
   will be too.
2. **Imperative verbs for action.** "Change X", "fix Y" — "can you suggest"
   yields suggestions, not changes.
3. **Say why, not just what.** Intent lets the model connect the task to the
   right information instead of inferring it. One clause of motivation per
   non-obvious constraint; for larger asks, lead with who it's for and what
   the output enables.
4. **Positive instructions over prohibitions** for behavior steering.
   (Guardrails are the exception: a boundary is clearest stated as a
   boundary.)
5. **Exit criteria are the definition of done — not verification orders.**
   State what must be true when the work is finished (commands that pass,
   observable behavior). Do NOT add "double-check", "re-verify", or "add a
   final verification step" — current models verify their own work unbidden,
   and stacked verification instructions add cost without quality.
6. **Ground, don't speculate.** Instruct: read the named files before making
   claims about them. Embed the verified `file:line` pointers as starting
   evidence.
7. **Numbered steps only when order is genuinely load-bearing** (a migration
   sequence, a deploy order). Otherwise prose goals — general instructions
   beat prescriptive step lists.
8. **Structure mixed content.** Separate instructions, data, and examples
   (fenced blocks or tags); long pasted material first, the ask last.
9. **Scope by outcome, not by file list.** The request itself sets the scope.
   Say what to leave out ("a pre-existing bug or cleanup the task doesn't
   need: report as a follow-up, don't fix here") rather than whitelisting
   permitted files. A hard file/path boundary appears only when blast radius
   genuinely demands one (money, schema, prod config).
10. **Honest escape hatch.** "If the task is infeasible or a test is itself
    wrong, report that instead of working around it."

## Anti-rules

- No model names, slugs, or pricing in refined prompts — they expire.
- No boilerplate sections: a section with nothing task-specific is omitted.
- The refined prompt must stay shorter than the rough prompt plus everything
  the pipeline learned. Length is a cost; every line must change behavior —
  and a line that dictates the how is a line that subtracts.

# Entry and exit criteria patterns

Entry criteria = the starting state that must hold before work begins.
Exit criteria = binary, checkable, tied to commands that actually exist in the
repo (CLAUDE.md, Makefile, package manifest — found in Stage 1). "Works better",
"is cleaner", "improved" are not exit criteria. If no runnable check exists for
the change, say so and propose one (e.g. "add a regression test at <path>");
never invent a command.

## Entry criteria (all genres)

State only what matters for this prompt, checked cheaply where possible:

- Branch and working-tree state (`git branch --show-current`, `git status`).
- Files/symbols the work builds on exist (verified in Stage 1, with `file:line`).
- Prerequisites: services running, env vars set, dependencies installed —
  as questions if unverifiable, never as assertions.
- Assumptions the prompt silently makes, surfaced explicitly ("assumes the
  flake reproduces locally").

## Exit criteria by genre

### fix
- A reproduction command that fails NOW (name it; if none exists, the first
  exit criterion is "write failing test at <path>").
- The same command passes after the change.
- The full relevant suite still passes (exact command from the repo).
- A regression test exists for the fixed behavior.

### build
- Named build/typecheck/lint/test commands pass (exact commands).
- The new behavior is demonstrable by one concrete invocation (a command, a
  route, a UI action) with the expected observable result stated.
- Tests cover the new logic's branches and edge cases, not padding.

### investigate  (no code changes)
- Deliverable is a written finding: root cause with `file:line` evidence.
- Verified claims and inferred claims are separated and labelled.
- Explicit criterion: "no files modified" — the working tree is untouched.

### research  (no code changes)
- Deliverable is a recommendation with 2–3 options and tradeoffs.
- Claims cite sources (repo code by `file:line`, external docs by URL).
- Explicit criterion: "no files modified".

### general
- At least one binary check, even if it is only "command X exits 0" or
  "output contains Y". A prompt with zero checkable outcomes gets a proposed
  check plus an open question.

### Sub-patterns (variants of the above)

- **Performance** (`fix` if a regression, else `build`): exit criteria are
  before/after numbers from a named benchmark or timing command. If none
  exists, the first exit criterion is creating one. "Faster" alone is banned.
- **Migration as the ask** (`build`): the schema-change stop-and-ask guardrail
  narrows to "migrations only within the named scope"; exit criteria include
  the migration applying AND rolling back cleanly (name both commands).
- **Test-writing** (`build`): exit criteria are "new tests fail when <specific
  behavior> is broken" (state how that was demonstrated) and the suite passes.
- **Docs-writing** (`general`): exit criteria are concrete content checks
  ("covers X, Y, Z", "commands in examples actually run"), not "command exits 0".

## Parallelization hint

If the refined task contains independent parts (multiple unrelated files,
separable subtasks), add one line to the refined prompt suggesting parallel
subagent fan-out. One line only; do not design the orchestration.

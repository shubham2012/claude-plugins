# prompt

## /prompt:grill `<rough idea>`

Interview-first spec building, for large or fuzzy asks where you want to be
questioned before anything is written. Batched option-based rounds (stop as
soon as answers stop changing the work; hard cap 3 rounds), grounded in the
repo so it never asks what the code already answers, then the same
outcome-spec and review gate as refine. Refine hands off to grill when it
finds more than three load-bearing unknowns.

# refine

A Claude Code plugin that turns a rough prompt into a repo-grounded spec —
entry criteria, exit criteria, guardrails — and gates execution behind your
review. Refinement is **opt-in per prompt**: nothing runs unless you invoke it.

## Usage

```
/prompt:refine fix the flaky billing test
```

For a non-trivial prompt you get exactly four parts:

- **a.** the refined prompt as one copyable block
- **b.** Corrections (`before → after`, or "no wording changes")
- **c.** Grounding (verified `file:line` facts vs `[unverified]`)
- **d.** up to three questions with options (omitted if none)

then a choice: **Run refined / Run refined, I'll edit first / Run original /
Cancel**. Nothing executes before you pick.

Trivial prompts ("what does this file do") pass straight through and execute
immediately — no rewrite, no commentary. Refusing to fire is the success case.

You can also just say "refine this prompt: ..." — the skill is model-invocable,
but only on an explicit ask. It never silently rewrites ordinary prompts.

## Install

From the marketplace (note: it lives in the `claude-plugins` repo, not a
repo named after this plugin):

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install prompt@dev-workflows
```

Local development:

```bash
claude plugin validate /path/to/prompt   # must print: ✔ Validation passed
claude --plugin-dir /path/to/prompt      # loads for that session
```

After edits during a session, run `/reload-plugins`.

To distribute, add the plugin to a marketplace repo and install with
`/plugin marketplace add <owner/repo>` then `/plugin install prompt@<marketplace>`.
See https://code.claude.com/docs/en/plugin-marketplaces.

## Uninstall

- `--plugin-dir` sessions: just start the next session without the flag.
- Marketplace installs: `/plugin` → prompt → uninstall.

## House style (optional)

Create `.claude/prompt-refine.local.md` in a project to teach the refiner your
conventions. Free-form notes apply everywhere; `## Exemplar: <genre>` sections
(genres: fix, build, investigate, research, general) show it what a good
refined prompt looks like in your house style — keep each exemplar under ~30
lines. Exemplars override the plugin's style guidance; its anti-rules (no model
names, no boilerplate, no padding) always win. Example:

```markdown
Branch names follow `sg/<ticket>-<slug>`. Exit criteria always include `make lint`.

## Exemplar: fix
Fix the race in claim() so concurrent claims never double-assign a worker
(evidence: worker/pool.go:112 check-then-set without synchronization).
Entry: on a `sg/*` branch, clean tree. Exit: `go test -race ./worker/...`
passes 20/20 consecutive runs. Guardrails: no public API changes; unrelated
cleanups become follow-up notes.
```

## Design constraints — read before "improving" this

**Hooks cannot rewrite prompts.** `UserPromptSubmit` hooks can only add context
(stdout / `additionalContext`) or block a prompt (exit 2). `updatedPrompt` is a
feature request, not a capability. Any "silent automatic improvement" design is
therefore impossible without a proxy — which is a non-goal. The rewrite happens
inside the conversation, on request. Docs: https://code.claude.com/docs/en/hooks

**There is deliberately no hook.** A plugin's `hooks/hooks.json` registers
automatically when the plugin is enabled — it cannot be made opt-in — and the
best a stdlib-only, no-model-call hook can do is inject a static nudge into
every prompt, forever. That is a permanent token tax for zero grounding. Cut.

**Token behavior.** Zero overhead until invoked. Trivial prompts load SKILL.md
only and short-circuit before any reference file. A typical non-trivial run
loads SKILL.md plus all four reference files (~2,200 words total) — the lazy
loading saves on the trivial path, not the full pipeline. The real downstream
savings: repo searching routes through an Explore subagent (>2 entities) so the
noise stays out of the main context, and verified `file:line` pointers ride
along in the refined prompt so execution doesn't re-search.

**No model-name/pricing tables anywhere.** They go stale. Prompting guidance
lives in `skills/refine/references/prompting.md` as model-agnostic rules with
source URLs for refreshing.

## Credits

Inspired by (ideas only — no code copied): genre-conditional criteria and the
exemplar file from GaZmagik/claude-prompt-improver; Explore-subagent grounding
and trivial-passthrough triage from severity1/claude-code-prompt-improver.

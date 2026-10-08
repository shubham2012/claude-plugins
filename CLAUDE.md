# claude-plugins — repo conventions

Open-source Claude Code plugin library. GitHub repo:
`shubham2012/claude-plugins`; marketplace name inside it: `dev-workflows`
(`/plugin marketplace add shubham2012/claude-plugins`, then
`/plugin install <plugin>@dev-workflows`).

## Commands

- `claude plugin validate .` and `claude plugin validate ./<plugin>`:
  verified: ran 2026-10-08, marketplace and all 9 plugins pass clean.
- Flags/subcommands confirmed in `--help`, not run here:
  `claude [-p] --plugin-dir ./<plugin>` (test without installing),
  `claude plugin marketplace update dev-workflows`,
  `claude plugin install|update <plugin>@dev-workflows`.
- CI: `.github/workflows/registry-check.yml` (job `sync`, every PR and push
  to main) fails if the `install-skills.sh` plugin list drifts from
  `marketplace.json` minus `wt`, a marketplace source lacks
  `.claude-plugin/plugin.json`, or a re-run of `install-skills.sh` fails to
  refresh its own (marker-tagged) skills or touches a user's same-named
  skill. All three ran locally 2026-10-08 and pass.

## Layout

Each plugin is a top-level directory:

```
<plugin>/
  .claude-plugin/plugin.json     # name, description, version — SHORT name (it's the slash prefix)
  skills/<skill>/SKILL.md        # one dir per skill; references/ subdir for lazy-loaded detail
  README.md
```

Every plugin is registered in `.claude-plugin/marketplace.json`. `install.sh`
reads that manifest dynamically, but `install-skills.sh` (the cross-tool
installer) carries a hardcoded plugin list: update it when adding a plugin
(CI fails if you don't). Also add a row per skill to the root README table;
nothing enforces that, so check it by hand. Use `skills/`, never the legacy
`commands/` dir.

Root files: `.claude-plugin/marketplace.json` (the manifest), `install.sh`
(Claude Code installer and updater), `install-skills.sh` (copies SKILL.md
folders into other tools), `.github/workflows/registry-check.yml`,
`LICENSE` (MIT). `ctx/` is the only plugin with hooks
(`ctx/hooks/hooks.json` plus two scripts).

## Adding or changing a plugin — the pattern

1. **Research before writing.** Fetch current schemas/behavior from
   code.claude.com/docs (hooks, skills, plugins) — never write them from
   memory. For a new domain, mine prior art (official + community plugins,
   local plugin caches). Mined content is a dated snapshot — label it with
   the date in the SKILL.md.
2. **Design rules (settled — don't relitigate without cause):**
   - **Spec the outcome, not the path.** Skills and the prompts they emit
     state goal/why/entry-exit criteria/boundaries; never step-by-step
     implementation plans or dictated change sites. `file:line` grounding is
     evidence, not restriction. Exit criteria are the definition of done —
     never "double-check/re-verify" orders (current models self-verify).
   - **Gates**: anything that creates/mutates/publishes goes behind
     AskUserQuestion. 4 options max (the tool's ceiling); the tool auto-adds
     a free-text "Other" — free text amends and re-gates, it NEVER executes,
     even when it reads as approval. Include an explicit "Wait. Do not act
     before the user chooses."
   - **Read-only is enforced, not promised**, via `allowed-tools` frontmatter
     — unless the whitelist would break the skill's real function (then
     prose + named forbidden tools, and say the trade-off in the README).
   - **Trivial passthrough is a success case**: skills that refine/groom/
     review must not fire ceremony on trivial inputs.
   - **Verified vs `[unverified]`** labeling everywhere; never invent paths,
     commands, or repo facts.
   - **Token rules**: SKILL.md small; references/ load lazily at the stage
     that needs them; no always-on hooks unless the value is per-event
     (compaction), never per-prompt.
3. **Adversarial review before shipping.** Spawn at least one different-model
   review agent on the new/changed files; hunt contract violations (paths
   that bypass gates), invented CLI flags/API fields, and unhandled edge
   cases (empty args, non-git dir, fork PRs, mid-flow entry). Fix high/med
   findings; discharge the rest with reasons in the commit message.
4. **Validate**: `claude plugin validate .` AND `claude plugin validate
   ./<plugin>` must pass with no warnings.
5. **Version-bump to propagate**: installed copies pin to plugin.json
   `version` — content changes without a bump silently don't reach users.
6. **Ship loop**: commit (conventional, one concern) → push →
   `claude plugin marketplace update dev-workflows` →
   `claude plugin install|update <plugin>@dev-workflows` → verify with a
   real invocation where feasible (headless `claude -p --plugin-dir` works
   for passthrough paths; interactive gates need a live session).

## Verified platform facts (recheck against docs if behavior looks off)

- Plugin skills are ALWAYS namespaced `/plugin-name:skill-name` — short
  invocations require short plugin names (that's why `prompt`, `pr`, `wt`).
- UserPromptSubmit hooks cannot rewrite prompt text — only add context or
  block. Silent prompt rewriting is impossible by design; don't try.
- Plugin hooks (hooks/hooks.json) auto-register when the plugin is enabled —
  they cannot be made opt-in within a plugin.
- PreCompact hook stdout is ADDED to the compaction summarizer's
  instructions; a non-zero exit BLOCKS compaction (hook scripts must exit 0).
  SessionStart(matcher "compact") stdout becomes post-compaction context.
- No settings key exists for default compaction instructions; hooks are the
  mechanism (see ctx/).
- `claude plugin eval` is early-access-gated. When available: add evals/ per
  plugin (contract cases like trivial-no-fire, gate-blocks-execution).
- AskUserQuestion: 2–4 options per question, "Other" auto-added, previews
  only on single-select.

## Writing style (prose the session produces)

Applies to READMEs, PR descriptions, commit messages, review replies, and any
other prose written while working here. This section is deliberately
self-contained — copy it into any repo's CLAUDE.md for the same effect.

Write like a person explaining something to a colleague, not like a report
generator. Lead with the point. Complete sentences in a natural register;
contractions are fine. Prefer plain words over formal ones ("use" not
"utilize", "so" not "therefore"). Vary sentence length the way speech does;
one idea per sentence beats subordinate-clause towers.

Avoid the tells of generated text: filler openers, hedging stacks ("it's
worth noting that"), symmetrical bullet lists where every item is exactly one
line, headers on three-paragraph documents, bolded topic sentences, and
closing summaries that restate what was just said. If a sentence doesn't
change what the reader knows or does, delete it. Punctuation is normal
punctuation — use whatever the sentence needs.

The goal is not to disguise anything; readable, direct prose is simply better
writing. Where a document has a required structure (RCA template, PR
template), the structure wins — write naturally inside it.

## House style for SKILL.md files

Under ~170 lines; stages/steps numbered; hard rules bold; banned outcomes
stated up front; every mined convention carries its mining date; cross-link
sibling skills where flows chain (/debug:rca → /ticket:groom, /wt:done after
/pr:ready).

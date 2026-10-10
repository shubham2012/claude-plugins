# onboard

## /onboard:agents `[repo path]`

The agent-docs doctor. Generates (CREATE) or refreshes (REFRESH) a repo's
CLAUDE.md / AGENTS.md by mining the repo itself:

- **Commands verified by running them** — everything in the doc is labeled
  `verified: ran` or `declared in CI, not run here`; a command that fails
  when run is reported as broken, never documented as working. Nothing
  state-mutating is ever executed.
- **Conventions mined from merged PRs**, each carrying its mining date so
  drift invites re-mining.
- **Never-rules only with evidence** — a hook, CI gate, doc, or review
  pattern that backs the rule; pointing at the enforcing check beats
  restating the rule.
- **REFRESH never deletes human-authored content**: claims are re-verified,
  corrected with evidence, or flagged — not silently kept or cut.
- **Each fact goes to the file that loads when it's needed.** Root
  CLAUDE.md, which loads every session, holds only what nearly every session
  needs (≤150 lines). Subtree conventions go to a nested CLAUDE.md, which
  loads when Claude touches that folder. Rules for a file kind go to
  `.claude/rules/*.md` with `paths:`, which loads on matching files.
  Occasional procedures go to a skill, where only the description is always
  loaded. Rules that must always hold become hook recommendations, never
  written automatically. Things an agent can learn by reading the code,
  linter-enforced rules and fast-changing facts are left out. In repos also
  used with Codex, AGENTS.md is the source of truth and CLAUDE.md imports it.
  The routing table and the loader facts behind it (verified 2026-10-10)
  live in `skills/agents/references/placement.md`.

Gated before writing: `Write to the repo` / markdown / revise / cancel. The
gate lists every file it would write, with its load trigger. Editing
existing nested or scoped files is opt-in.

**Trade-off, stated plainly**: this skill executes repo commands and writes
files by design, so it cannot be `allowed-tools`-restricted to read-only like
/pr:review. Its safety rests on the stated boundary (read script bodies
before running; dry-run as the default probe; never migrations, deploys, or
state mutation) plus the write gate — a documented convention, not an
enforced whitelist. Treat its runs accordingly in sensitive repos.

Why this plugin exists: a good agent doc is the highest-leverage grounding a
repo can have — it improves every prompt in every session, including every
other skill in this registry.

## Install

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install onboard@dev-workflows
```

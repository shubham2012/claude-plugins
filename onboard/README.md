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
- Output stays small (≤150 lines target) — agent docs load every session,
  so every line is a standing token cost.

Gated before writing: `Write to the repo` / markdown / revise / cancel.

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

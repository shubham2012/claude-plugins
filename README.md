# claude-plugins

Engineering-workflow plugins for [Claude Code](https://code.claude.com):
prompt refining, PR lifecycle, ticket grooming, debugging, worktrees, and
context continuity. Each plugin is independent — install only what you want.

| Plugin | Skill | What it does |
|---|---|---|
| [prompt](./prompt/) | `/prompt:refine` | Rough prompt → repo-grounded spec (entry/exit criteria, guardrails), gated behind your review |
| [pr](./pr/) | `/pr:ready` | Drive a PR to approved: CI green, every comment addressed, ≤5 cycles, never merges |
| [pr](./pr/) | `/pr:review` | Advisory house-checklist review of the failure classes human reviewers actually flag |
| [ticket](./ticket/) | `/ticket:groom` | Vague report/thread → well-formed tracker issue (Linear or GitHub Issues) with binary acceptance criteria, gated |
| [debug](./debug/) | `/debug:triage` | Incident first response: correlate, timeline, status drafts — read-only, you approve every action |
| [debug](./debug/) | `/debug:repro` | Production stack trace/error → minimal failing test with the same error signature |
| [debug](./debug/) | `/debug:flaky` | Flake rate → cause class with evidence → fix the cause; proof is 20 consecutive passes + revert re-flake |
| [debug](./debug/) | `/debug:rca` | Narrative-with-numbers postmortem: evidenced cause chain, prevent/detect/shrink follow-ups |
| [wt](./wt/) | `/wt:new` | Worktree from latest origin default branch, session switched into it |
| [wt](./wt/) | `/wt:done` | Gated worktree wrap-up: PR-merged + clean-tree check, then remove/keep on your choice |
| [ctx](./ctx/) | (hooks) | Every compaction auto-preserves decisions, scope, plan, bugs; post-compaction re-grounding nudge |
| [ctx](./ctx/) | `/ctx:save` | Durable session-state snapshot per branch — survives compaction, /clear, crashes |
| [ctx](./ctx/) | `/ctx:resume` | Restore from snapshot, verified against the actual repo state, drift reported |

## Install

Everything, one command:

```bash
curl -fsSL https://raw.githubusercontent.com/shubham2012/claude-plugins/main/install.sh | sh
```

Or pick individual plugins inside any Claude Code session:

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install <prompt|pr|ticket|debug|wt|ctx>@claude-plugins
```

Update later with `/plugin update <plugin>@claude-plugins`; uninstall via
`/plugin`.

## Design principles

- **Spec the outcome, not the path** — skills and the prompts they emit state
  goal/why/criteria/boundaries and let the model determine the how (per
  Anthropic's current-model prompting guidance).
- **Gates over trust** — anything that creates, mutates, or publishes sits
  behind an explicit multiple-choice review; free-text answers amend and
  re-gate, never execute.
- **Verified vs `[unverified]`** — no invented paths, commands, or repo facts.
- **Trivial passthrough is a success case** — no ceremony on inputs that don't
  need it.
- **Token-frugal** — zero overhead until invoked; references lazy-load;
  hooks fire per-event (compaction), never per-prompt.

See [CLAUDE.md](./CLAUDE.md) for the full contribution pattern.

## License

[MIT](./LICENSE)

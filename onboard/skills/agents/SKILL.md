---
name: agents
description: Generate or refresh a repo's agent docs (CLAUDE.md / AGENTS.md) by mining the repo itself — build/test commands verified by running them, conventions mined from merged PRs, never-rules from evidence — then gate before writing anything. Use when a repo lacks agent docs, they look stale, or the user invokes /onboard:agents.
argument-hint: [repo path — defaults to the current repo]
---

# Agent Docs Doctor

Target: $ARGUMENTS (empty → the current repo; not a git repo or empty dir →
say so and stop — there is nothing to mine).

A good agent doc is the highest-leverage grounding a repo can have: it loads
every session and improves every prompt. It's also a liability when wrong —
so nothing goes in it unverified, and it stays SMALL (target ≤150 lines;
detail links out to deeper docs, it doesn't move in).

## 0. Inventory → mode

Find what exists: CLAUDE.md, AGENTS.md, per-subtree agent files, README,
CONTRIBUTING, .githooks, CI workflows, PULL_REQUEST_TEMPLATE.

**Scope before mode**: the default target is ONE document — the root (or
nearest) agent doc. Other agent files found (per-subtree AGENTS.md etc.) are
NAMED to the user, and widening to them is opt-in, never assumed; on a
monorepo, "refresh everything" is a decision the user makes per file, not a
side effect. The gate's diff summary names exactly which paths would be
written. Mode:

- **CREATE** — nothing exists. Follow the org pattern if one is visible
  (e.g. AGENTS.md as the source of truth with CLAUDE.md as a one-line
  `@./AGENTS.md` include); otherwise plain CLAUDE.md. Confirm the choice in
  the gate, not by asking up front.
- **REFRESH** — docs exist. Human-authored content is never deleted: claims
  are re-verified against today's repo, confirmed ones stay, broken ones are
  corrected with the evidence noted, and anything unverifiable is flagged to
  the user rather than silently kept or cut.

## 1. Mine commands — and verify by running

From Makefile/manifests/CI workflows, collect build/test/lint/generate
commands. **Read the target/script body BEFORE running anything** — these
are teammate-authored strings you're about to execute. Run a command only
when what it does is visible and confined to reading plus build artifacts
in ignored paths. The known traps: npm/yarn lifecycle scripts (`prebuild`/
`postbuild` run silently), Make targets that shell out to other scripts,
anything touching a database, network service, or cloud credential. The
safe default probe is `make -n <target>` / the tool's `--dry-run`; lint
and typecheck are usually safe to run for real. Never run migrations,
deploys, or anything that mutates state beyond ignored build output.

Every command in the final doc carries an honest label:

- **verified: ran** — executed here and exited clean.
- **declared in CI, not run here** — long suites and anything needing
  services/credentials; named with the CI job that runs it.

A command that fails when run does NOT go in the doc as working — it goes
in the report as broken (that finding alone often justifies the refresh).

## 2. Mine conventions (dated snapshot)

From the last ~15 merged PRs (`gh pr list --state merged`): title format,
branch naming, description shape, merge method. From review comments if
cheap: recurring house rules. Every mined convention in the doc carries its
mining date — conventions drift, and a dated claim invites re-mining;
an undated one masquerades as timeless.

## 3. Map the repo

Top-level directories with one-line purposes (read enough to be right, not
exhaustive); entry points; where tests live; anything surprising a new
session would waste time rediscovering.

## 4. Never-rules — evidence-backed only

Collect the repo's hard rules from existing docs, lint configs, hooks, and
CI gates (e.g. "money is NUMERIC, never float", "no bare NOT NULL on live
columns"). A never-rule needs evidence: a hook that enforces it, a doc that
states it, or a review comment pattern — never invented from general best
practice. Prefer pointing at the enforcing check over restating the rule.

## 5. Draft

Assemble, smallest-first: commands (with labels) → conventions (dated) →
repo map → never-rules → optional writing-style section (offer it; the
registry's CLAUDE.md carries a self-contained one to copy). Structure and
tone match the org's existing agent docs where they exist. The doc states
facts, not aspirations — nothing "should"; either it is, or it's out.

## 5.5 Reader test — the doc's audience is a fresh agent, so test with one

Use the Agent tool with ONE fresh general-purpose subagent — never a fork,
which inherits this conversation and already knows the answers, silently
voiding the test. Pass ONLY the drafted doc text in its prompt, instruct it
to answer FROM THE DOC ALONE (not by reading the repo), and ask it 3-5
realistic session-start questions ("what command runs
the tests?", "where does <core concept> live?", "what must never be done in
migrations here?"). Wrong or unanswerable answers mean the DOC failed, not
the reader — fix the doc and note what the test caught. This is the check
that fails: a doc that reads well to you but can't answer a fresh agent's
questions is exactly the failure mode agent docs exist to prevent.

## 6. Gate, then write

Present the full draft plus a one-line diff summary in REFRESH mode
(kept / corrected / flagged counts). AskUserQuestion (`header: "Docs"`),
exactly:

1. `Write to the repo` — write the file(s); the user commits/PRs them.
2. `Give me the markdown` — copyable block, write nothing.
3. `Revise` — apply, re-gate (after 3 cycles, offer markdown).
4. `Cancel`.

Wait — do NOT write before the user chooses. Free-text ("Other") answers
revise and re-gate, never write, even when they read as approval; only the
literal `Write to the repo` selection writes.

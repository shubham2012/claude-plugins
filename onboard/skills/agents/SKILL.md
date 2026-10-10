---
name: agents
description: Generate or refresh a repo's agent docs (CLAUDE.md / AGENTS.md, nested CLAUDE.md, path-scoped .claude/rules, skills) by mining the repo itself — build/test commands verified by running them, conventions mined from merged PRs, never-rules from evidence — routing each fact to the file that loads when it's needed, then gate before writing anything. Use when a repo lacks agent docs, they look stale or bloated, or the user invokes /onboard:agents.
argument-hint: [repo path — defaults to the current repo]
---

# Agent Docs Doctor

Target: $ARGUMENTS (empty → the current repo; not a git repo or empty dir →
say so and stop — there is nothing to mine).

A good agent doc is the highest-leverage grounding a repo can have: it loads
every session and improves every prompt. It's also a liability when wrong —
so nothing goes in it unverified, and the root stays SMALL (target ≤150
lines). What doesn't belong in every session goes to a file that loads only
when it's relevant (Stage 4.5), not into the root.

## 0. Inventory → mode

Find what exists: root and nested CLAUDE.md / CLAUDE.local.md / AGENTS.md,
`.claude/rules/`, `.claude/skills/`, hooks in `.claude/settings.json`,
README, CONTRIBUTING, .githooks, CI workflows, PULL_REQUEST_TEMPLATE. Note
whether the team also uses AGENTS.md tools (Codex etc.): an existing
AGENTS.md, `.codex/`, or docs that mention them.

**Scope before mode**: the default target is the root agent doc plus any
NEW scoped files Stage 4.5 proposes. EXISTING nested or scoped files are
NAMED to the user, and editing them is opt-in, never assumed; on a
monorepo, "refresh everything" is a decision the user makes per file, not a
side effect. The gate's diff summary names exactly which paths would be
written. Mode:

- **CREATE** — nothing exists. Follow the org pattern if one is visible
  (e.g. AGENTS.md as the source of truth with CLAUDE.md as a one-line
  `@AGENTS.md` import); otherwise plain CLAUDE.md. Confirm the choice in
  the gate, not by asking up front.
- **REFRESH** — docs exist. Human-authored content is never deleted: claims
  are re-verified against today's repo, confirmed ones stay, broken ones are
  corrected with the evidence noted, and anything unverifiable is flagged to
  the user rather than silently kept or cut. Moving a confirmed line to a
  better-scoped file (Stage 4.5) is allowed and reported as **moved**, with
  its old and new location. A move whose source or destination is an
  EXISTING nested or scoped file is an edit to that file, so it's opt-in
  like any other. Without the opt-in it's listed as a suggestion.

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

## 3. Map the repo — only what reading it wouldn't tell

An agent reads the tree itself, so a directory listing or tech-stack summary
is dead weight. Record only what reading would get wrong or miss: an
entry point that isn't where it looks, tests that live somewhere
unexpected, generated or vendored code not to edit, a misleadingly named
directory. Also note the subtrees with conventions of their own (packages,
services, apps), since Stage 4.5 may give them a nested file.

## 4. Never-rules — evidence-backed only

Collect the repo's hard rules from existing docs, lint configs, hooks, and
CI gates (e.g. "money is NUMERIC, never float", "no bare NOT NULL on live
columns"). A never-rule needs evidence: a hook that enforces it, a doc that
states it, or a review comment pattern — never invented from general best
practice. Prefer pointing at the enforcing check over restating the rule.
A rule a linter or type checker already enforces gets a pointer to its
config, not a restatement.

## 4.5 Route — every fact to the file that loads when it's needed

Read `references/placement.md` now. Then give each fact from Stages 1-4
one destination: root CLAUDE.md (needed in nearly every session), a nested
CLAUDE.md (one subtree), a `.claude/rules/<topic>.md` with `paths:` (a file
kind across directories), a skill (a procedure needed sometimes), a hook
**recommendation** (must always hold and a script can check it), or out
(discoverable by reading, linter-enforced, or changing weekly). Rules:

- **Default to root.** Scope a fact only when you can name the paths or the
  task it applies to. A guessed glob that misses hides the rule exactly when
  it matters. Check every `paths:` glob against `git ls-files`: one that
  matches nothing is a bug.
- **No new file for one line.** A scoped file earns its existence with a
  few facts that belong together.
- **Skills only from what's already written down.** Draft a skill only from
  a procedure the repo already documents (a runbook, a CONTRIBUTING
  section), verified like everything else, with a one-line description,
  because that description loads every session. A procedure that isn't
  written down yet is reported as a suggested skill, not authored.
- **Hooks are recommended, never written.** The report names the event, the
  check, and the rule it enforces, and skips rules an existing hook already
  enforces. Writing settings is out of scope.
- **Everything routes to root?** That's the normal result for a small repo.
  Say so in one line, skip scoped drafting and the "Where else to look"
  list, and carry on as a single-file run.
- **Multi-tool repos** (Stage 0): AGENTS.md is the source of truth and
  CLAUDE.md imports it with `@AGENTS.md`. Facts other tools also need go in a
  nested AGENTS.md, not in `.claude/rules/`, which only Claude Code reads.

## 5. Draft

Assemble the root smallest-first: commands (with labels) → conventions
(dated) → non-obvious map → never-rules → a short "Where else to look" list
naming each scoped file and when it loads → optional writing-style section
(offer it; the registry's CLAUDE.md carries a self-contained one to copy).
Then draft each scoped file from Stage 4.5. Structure and tone match the
org's existing agent docs where they exist. The docs state facts, not
aspirations — nothing "should"; either it is, or it's out.

## 5.5 Reader test — the doc's audience is a fresh agent, so test with one

Use the Agent tool with ONE fresh general-purpose subagent — never a fork,
which inherits this conversation and already knows the answers, silently
voiding the test. Pass ONLY the drafted docs in its prompt: the root doc
first, then each scoped file labeled with when it loads ("loads when
editing db/migrations/**/*.sql"). Instruct it to answer FROM THE DOCS ALONE
(not by reading the repo), and ask it 3-5 realistic questions ("what command
runs the tests?"). For each scoped file, one question names a real path
from `git ls-files` ("I'm editing db/migrations/0042_x.sql: what must I
never do?"). Before asking, confirm the path matches that file's `paths:`
glob or sits under its subtree, so the test exercises the real trigger. A
wrong answer means the DOCS failed, not the reader. Fix them and note what
the test caught.
This is the check that fails: docs that read well to you but can't answer a
fresh agent's questions are exactly the failure mode they exist to prevent.

## 6. Gate, then write

Present every drafted file with its path and load trigger, the hook
recommendations, and in REFRESH mode a one-line diff summary
(kept / corrected / moved / flagged counts). AskUserQuestion
(`header: "Docs"`), exactly:

1. `Write to the repo` — write exactly the listed files (including any
   `@AGENTS.md` import stubs and new `.claude/` directories); the user
   commits/PRs them.
2. `Give me the markdown` — copyable block, write nothing.
3. `Revise` — apply, re-gate (after 3 cycles, offer markdown).
4. `Cancel`.

Wait — do NOT write before the user chooses. Free-text ("Other") answers
revise and re-gate, never write, even when they read as approval; only the
literal `Write to the repo` selection writes.

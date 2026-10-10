# Placement: route each fact to the loader that fits it

Verified 2026-10-10 against code.claude.com/docs/en/memory, /skills and
/best-practices, plus OpenAI's Codex AGENTS.md guide. Loader behavior
changes, so re-check these pages if anything below looks off.

The question for every candidate line: **when does an agent need this, and
what does it cost if it's always loaded?** Root CLAUDE.md is paid for in
every session. Everything else is paid for only when it's relevant.

## Destinations

| Content | Destination | When it loads |
|---|---|---|
| Can't-guess commands, cross-cutting conventions, repo-wide gotchas, PR/branch etiquette | Root `CLAUDE.md` | Every session, at launch |
| Conventions for one subtree (a package, service, or app in a monorepo) | `<subdir>/CLAUDE.md` | Once Claude reads, writes, or edits a file in that subdirectory |
| Rules for a file kind that cuts across directories (migrations, `*.sql`, `**/*.test.ts`, generated code) | `.claude/rules/<topic>.md` with `paths:` frontmatter | When Claude reads, writes, or edits a matching file |
| Multi-step procedures or domain knowledge needed sometimes (release, migration authoring, incident steps, a subsystem's API conventions) | `.claude/skills/<name>/SKILL.md` | Description at launch; body only when invoked or judged relevant |
| A rule that must hold every time and a script can check (block edits to a path, run a formatter after edits) | A hook, recommended in the report, never auto-written | On its lifecycle event, deterministically |
| Personal preferences | `CLAUDE.local.md` (gitignored) or `~/.claude/` | Never written by this skill |

Path-scoped rule format. `paths` is the only key Claude Code reads; any
other key is ignored:

```markdown
---
paths:
  - "db/migrations/**/*.sql"
---
Every migration states its rollback. No bare NOT NULL on a live column.
```

A rule file **without** `paths` loads at launch at the same priority as
`.claude/CLAUDE.md`. That's a way to split a long root doc by topic, not a
way to save context. Our heuristic: use it only when the root doc would
otherwise go past the docs' 200-line target.

## Leave out entirely

- Anything an agent learns by reading the code: directory listings, the
  tech stack, file-by-file descriptions. A repo map earns a line only for
  what reading the tree would mislead about.
- Rules a linter, formatter, or type checker already enforces. Point at the
  config file instead.
- Tutorials, long explanations, and full API references. Link to them.
- Information that changes weekly.
- Self-evident advice ("write clean code").

## Size and imports

- Target under 200 lines per CLAUDE.md file. Longer files cost more context
  and get followed less. This skill aims for ≤150 for root.
- `@path` imports go at most 4 hops deep and **still load at launch**, so
  they organize a file without making it cheaper. To defer cost, move the
  content to a nested CLAUDE.md, a scoped rule, or a skill.

## AGENTS.md and other tools

- Claude Code reads `AGENTS.md` natively only when no `CLAUDE.md` exists in
  the working directory or above it. If both exist, only CLAUDE.md loads,
  unless the user changes the **Project instructions** setting.
- Repo also used with Codex or other AGENTS.md tools: keep `AGENTS.md` as
  the source of truth and make `CLAUDE.md` a one-line `@AGENTS.md` import,
  at root and in each subtree that has one.
- Codex concatenates nested `AGENTS.md` files from the root down to the
  working directory when it starts, with closer files last, so they win.
  The combined size is capped at 32 KiB by default (`project_doc_max_bytes`).
  Lazy loading is a Claude Code behavior; Codex pays for the whole chain.
- `.claude/rules/` and `.claude/skills/` are Claude Code mechanisms. For
  rules other tools also need, use a nested `AGENTS.md` in the directory
  where they apply.

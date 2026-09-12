# Guardrail catalogue

Derive from the specific prompt; include only guardrails the prompt actually
implies. Pasting this list wholesale is a defect — a guardrail nobody needed is
noise that dilutes the ones that matter.

Guardrails are deliberately prohibition-shaped ("do not X", "stop before Y") —
the wording pass's prefer-positive-instructions rule applies to action
statements, not to these. A boundary is clearest stated as a boundary.

## Scope (boundaries, not solutioning)

The request itself sets the scope — the model determines where the change
lands. Scope guardrails say what to LEAVE OUT, never which files to modify:

- "A pre-existing bug, performance concern, or cleanup the task doesn't need:
  report it as a follow-up, don't fix it in this change."
- "Do not reformat, rename, or improve unrelated code."
- A hard path boundary ("nothing under `db/migrations/`") only when the
  prompt implies real blast-radius risk — money, schema, auth, prod config —
  never as a way to dictate the implementation site. Naming the one file the
  model may touch is prescribing the solution; current models do worse when
  the path is dictated.

## Forbidden actions

Include when the genre or target implies the risk:

- No new dependencies (any genre touching a manifest).
- No weakening, skipping, or deleting tests to go green (`fix`, `build`).
- No hardcoding values that only satisfy the named test cases — implement the
  general logic (`fix`).
- No schema or migration changes (anything near models/DB).
- No changes at all (`investigate`, `research`).

## Stop-and-ask triggers

The work pauses for the user when it would:

- Delete files or branches.
- Add a dependency or change a manifest/lockfile.
- Alter a schema, run a migration, or touch generated code.
- Touch anything on a money, billing, auth, or production-config path.
- Push, publish, or message anything outside the repo.

## Undo path

- Default: work on a branch; undo is `git checkout -- <paths>` /
  `git revert <commit>`. Name the branch if entry criteria set one.
- If the repo is not git-tracked or the change is outside git (env, DB, deploy),
  state the actual undo mechanism — and if there is none, that itself is a
  stop-and-ask trigger.

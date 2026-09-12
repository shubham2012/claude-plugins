---
name: ready
description: Drive the current branch's PR to approved and mergeable — open it if missing, make CI pass, address every review comment, loop up to 5 cycles, then summarize what's done and what needs the user. Use when the user says "ready PR", "get this PR merged", or invokes /pr:ready.
argument-hint: [PR number or URL — defaults to the current branch's PR]
---

# Ready PR

Target: $ARGUMENTS (empty → the current branch's open PR, via
`gh pr view --json number,url,state,isDraft,isCrossRepository,maintainerCanModify,headRepositoryOwner,author`).

Drive the PR to **approved with all comments resolved**, or stop at the hard
cap. **Never run `gh pr merge` in any form — including `--auto`, `--admin`,
`--squash` — and never enable auto-merge via API or UI.** Enqueueing a merge is
merging. The merge is the user's click unless they explicitly say otherwise.

## Step 0 — Eligibility gates (re-checked at the top of every cycle)

- Closed or merged → stop, say so in one line.
- Draft → stop and ask whether to mark it ready; only on explicit confirmation
  run `gh pr ready <n>` (it notifies reviewers).
- **Writability**: if the PR is cross-repository without `maintainerCanModify`,
  or its author isn't the current user (`gh api user`), switch to ADVISORY
  mode — report what needs doing (CI fixes, thread answers) and stop; never
  attempt pushes, replies, or resolves on a PR you can't or shouldn't write to.
- No PR yet → confirm the branch is pushed, then `gh pr create`:
  - Follow the repo's PULL_REQUEST_TEMPLATE if one exists — never bypass it.
  - Title mirrors the repo's observed convention (check the last ~10 merged
    PR titles; copy their format).
  - Description: what changed, why, how it was tested — name the commands run
    and their results, never an unqualified "tested locally".
- On the default branch with unpushed work → stop and ask; never push to it.

**Repo conventions are discovered, not assumed:** mirror what the last ~10
merged PRs actually do — title format, branch naming, description shape. A
good default description when no template or convention exists: `## Summary`
+ `## Test plan` (checkboxes naming specific tests) + `## Validation` (exact
commands + results). If the repo squash-merges, the PR title becomes the
commit — keep it clean. Do not assume branch protection exists — treat CI
green + review as required regardless.

## The loop (hard cap: 5 cycles — never exceed it)

### 1. CI
`gh pr checks <n> --json name,state,link` lists checks and links to their
runs. For each failure, extract the run ID from the link and read the actual
log with `gh run view <run-id> --log-failed` (never bare `gh run view` — it
opens an interactive picker). Fix the cause, push. Never weaken, skip, or
delete a test to go green; never bypass hooks with `--no-verify` — pre-commit/pre-push hooks (linters,
generated-code checks) exist precisely to fail; fix the cause instead.

**Flake budget**: a check that failed for infrastructure reasons (flake,
runner death) gets ONE re-run per check for the whole invocation — track
which checks you've re-run; a new cycle never refreshes the budget. Waiting
on a re-run doesn't consume a cycle.

### 2. Review threads
Fetch unresolved threads via GraphQL (REST misses resolution state):

```
gh api graphql -f query='query($o:String!,$r:String!,$n:Int!,$c:String){
  repository(owner:$o,name:$r){pullRequest(number:$n){
    reviewThreads(first:100,after:$c){pageInfo{hasNextPage endCursor}
      nodes{id isResolved isOutdated path line
        viewerCanReply viewerCanResolve
        comments(first:20){nodes{author{login __typename} body}}}}}}}' \
  -f o=<owner> -f r=<repo> -F n=<pr>
```
Paginate via `-f c=<endCursor>` while `hasNextPage`. Reply with the
`addPullRequestReviewThreadReply` mutation (input: `pullRequestReviewThreadId`,
`body`); resolve with `resolveReviewThread` (input: `threadId`) — and only
after the fix is in the pushed HEAD. A thread with `viewerCanReply: false` is
reported to the user, never retried.

For each unresolved thread:

- **Bot vs human**: classify on `author.__typename == "Bot"` (authoritative;
  `[bot]` login suffixes are a secondary signal). Review bots — CodeRabbit,
  Copilot, in-house reviewers — vary per repo; some self-resolve threads or
  support re-run commands, so check how this repo's bots behave before
  fighting them. Bot findings are VERIFIED against the code before acting —
  bots hallucinate. Human findings are also verified (reviewers can be wrong),
  but disagreement goes back as a reply, never silent inaction.
- **isOutdated threads**: check whether current HEAD already addresses the
  comment before doing new work — don't re-litigate stale line references.
- **Classify** before acting:
  - FIX now: real bugs, security issues, missing error handling, test gaps,
    style violations the repo's linter/conventions back up.
  - REPLY with justification: subjective preference, suggestions that
    contradict the verified code, architectural rewrites beyond this PR's
    scope (offer a follow-up ticket instead).
  - ASK the reviewer: feedback with two valid interpretations — reply asking
    them to pick; the thread counts as addressed-pending-them.
- Every thread gets a commit+reply or a reply — never a silent resolve.
- **Idempotency**: skip threads you already replied to in a previous cycle
  unless the reviewer responded since.

### 3. Re-check and exit
After pushes, re-poll checks and threads. Exit when: approved AND no
unresolved threads AND CI green → done. Cap reached → done (partial).

## Guardrails

- Commits are atomic and conventional; one concern each. No drive-by refactors
  of untouched code.
- **No force-pushes unless the user explicitly asked.** When they did: first
  run `git log --format='%ae' origin/<base>..HEAD | sort -u` and abort if any
  author isn't the user; then push only with `--force-with-lease` and an
  explicit refspec.
- Anything a reviewer flags on money, billing, auth, schema, or production
  config paths: fix conservatively or escalate to the user — never argue past.

## On exit (always, both outcomes)

1. Addressed: each thread → commit link or justification; each CI fix.
2. Still open: threads waiting on reviewers, pending checks.
3. Needs the user: decisions only they can make; whether the PR is mergeable
   right now.

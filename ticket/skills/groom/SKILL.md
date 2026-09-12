---
name: groom
description: Turn a vague bug report, pasted thread, error output, or half-formed idea into a well-formed tracker issue (Linear or GitHub Issues) with repro steps, expected vs actual, and binary acceptance criteria — gated behind the user's review before anything is created. Use when the user asks to file, groom, or write up a ticket/issue, or invokes /ticket:groom.
argument-hint: <raw report: bug description, pasted thread, error output, or idea>
---

# Ticket Groom

Raw input: $ARGUMENTS

If empty, take it from the user's most recent message; if none exists, ask and
stop. The deliverable is a DRAFT presented for review — nothing is created in
Linear until the user approves.

## 1. Extract, don't invent

Pull from the raw input only: observed behavior, expected behavior, error text
(verbatim, trimmed), affected surface (service/page/endpoint), who reported it,
when. Anything the input doesn't state is either omitted or listed as an open
question — never fabricated. A pasted thread is read in full before extracting;
the load-bearing detail is routinely in the last few messages.

## 2. Ground in the repo (only if a repo is open)

If the report names code artifacts (a service, endpoint, file, error string),
resolve them with Grep/Glob — an error string grepped to its source file turns
"payments are broken" into a `file:line` anchor. Never guess a path. Skip
entirely when no repo context exists.

## 3. Duplicate check (cheap, before drafting)

Search the project's tracker — Linear via its MCP tools if connected, else
GitHub Issues via `gh issue list --search` — for the 2-3 most distinctive terms from the
report (error strings beat descriptions). Judge overlap by shared distinctive terms, not
topic: same root symptom → propose linking/commenting on the existing issue
instead of filing new. When unsure whether it's a dupe, that becomes a
question in step 5, not a silent decision.

## 4. Classify: symptom or root cause

State which one the ticket describes. A symptom ticket names the observable
("checkout 500s for EU users"); if the root cause is already known from
grounding, say so in the ticket body but keep the title on the observable —
the fix retires the symptom, and the test is "would this fix close the
ticket?". Never title a ticket with a guessed cause.

## 5. Draft in this shape

```
Title: <observable behavior, one line, no guessed cause>

**What happens:** <actual, with verbatim error text>
**Expected:** <expected>
**Repro:** <numbered steps, or "not yet reproduced — see questions">
**Evidence:** <file:line anchors, log/trace links, thread link — verified only>
**Acceptance criteria:** <binary, checkable — "X returns 200 for EU carts",
  "regression test at <path> passes". "Works properly" is banned.>
**Open questions:** <max 3, each with options — omit if none>
```

Omit empty sections. Severity/priority, team, and labels: propose them from
what Linear's own metadata shows similar issues using, but mark each as a
proposal — when in doubt leave unset and ask; a wrong label is worse than a
missing one.

## 6. Gate

Present the draft, then AskUserQuestion (`header: "Ticket"`) with exactly
these four options (four is the tool's ceiling — never add a fifth):

1. `Create the issue` — create it in the tracker, report the issue URL.
2. `Create, I'll edit first` — stop; user edits, next pasted version is
   created directly without re-grooming.
3. `Just give me the text` — output the draft as one copyable block; create
   nothing.
4. `Cancel` — stop.

Wait. Do NOT create anything before the user chooses. A free-text ("Other")
answer amends the draft and re-gates with the same four options — NEVER create
the issue from free text, even text that reads as approval ("yes, file it");
only the literal `Create the issue` / `Create, I'll edit first` selections
create.

Creation targets whichever tracker the session has: Linear via
`mcp__linear__save_issue` with NO id (passing an id updates; omitting creates)
or GitHub Issues via `gh issue create`. If no tracker is reachable OR calls
error (including auth failures): say so once, don't retry, and fall back to
option 3 behavior.

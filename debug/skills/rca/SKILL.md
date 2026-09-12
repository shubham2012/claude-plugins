---
name: rca
description: Write the post-incident root cause analysis in narrative-with-numbers style, evidence-anchored cause chain, follow-ups as groomable tickets. Use after an incident is resolved, when the user asks for a postmortem/RCA, or invokes /debug:rca.
argument-hint: <incident: timeline from /debug:triage, PR/thread links, or a description>
---

# Root Cause Analysis

Input: $ARGUMENTS — a /debug:triage timeline, PR or Slack links, log excerpts,
or a prose description. If empty, ask what incident this is for and stop.

House style: **narrative with numbers** — written to live inside the fixing
PR's body or a doc, not a heavyweight SEV template. Quantified blast radius
("15 reset incidents on 9 of 14 days; 3 of ~392 sessions"), exact timestamps,
trace/session IDs. Blameless throughout: mechanisms and conditions, never
people; "the deploy lacked X" not "someone forgot X".

## 1. Verify before narrating

Every factual claim gets checked against something — a log line, a deploy
record, a commit, a pasted message — or is labeled **inferred**. Where the
input is a triage timeline, its inferred entries stay inferred here unless
you can now corroborate them. Fill gaps by asking or by reading (git log,
merged PRs in the window), never by smoothing the story.

## 2. The cause chain

Walk from symptom to root cause, one evidenced link at a time (`file:line`,
commit, config change per link). Stop at the deepest cause the evidence
supports and say plainly when it's "suspected, not confirmed" — a confident
wrong root cause is worse than an honest open one. Separately list
**contributing factors** (what made it worse or slower to catch: missing
alert, silent fallback, telemetry gap) — most incidents have one cause and
three amplifiers, and the amplifiers are where the durable fixes live.

## 3. The write-up shape

```
## What happened
<2-4 sentences, narrative with numbers>

## Impact
<who/what, quantified; duration; money/data exposure if any>

## Timeline (UTC)
<timestamped entries, verified vs inferred labeled>

## Root cause
<the chain, each link evidenced>

## Contributing factors
<amplifiers, each with its evidence>

## What went well / what didn't
<detection, escalation, mitigation — honest, short>

## Follow-ups
<each: action, owner-shaped, and whether it's prevention, detection, or
mitigation. Every one is /ticket:groom material — offer to groom them.>
```

Omit sections with nothing real to say. The whole thing should paste cleanly
into the fixing PR's description or a doc — that's where these live here.

## 4. The follow-up test

Each follow-up must pass: "would this have prevented, detected sooner, or
shrunk this incident?" — name which. Per house principle, prefer a check that
fails over a convention that is documented: an alert, a CI gate, a constraint
— not a wiki page saying "remember to X". If the incident exposed a runbook
or alert gap, that gap is itself a follow-up.

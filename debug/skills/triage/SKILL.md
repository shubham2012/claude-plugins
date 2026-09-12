---
name: triage
description: On-call first response for an alert or incident — establish severity, correlate with recent deploys/logs/metrics, build a verified timeline, and draft structured status updates. Read-only by default; every mutating or customer-visible action is gated behind the user. Use when the user is paged, pastes an alert, or invokes /debug:triage.
argument-hint: <incident id, alert text, or a description of what's firing>
---

# Incident Triage

Input: $ARGUMENTS (an incident ID, pasted alert, or symptom description).
If empty, ask what's firing and stop.

**Prime directive: this skill is read-only.** It investigates, correlates, and
drafts. Restarts, rollbacks, scaling, feature-flag flips, config changes, and
any customer-visible communication are proposed with evidence and executed only
after the user explicitly approves that specific action. Investigation never
becomes mitigation on its own.

## 0 — Tooling check (10 seconds, once)

Use what this session actually has: PagerDuty / CloudWatch / Datadog / Slack
tools if connected (load via ToolSearch), else `gh`, `kubectl`, and asking the
user to paste dashboards. Name what's missing once ("no Datadog access — paste
the relevant graph if useful") and work with the rest. Never fake a data
source. Read-only means read-only tools: never call incident-mutating or
message-sending tools (`manage_incidents`, `create_incident`,
`add_note_to_incident`, `slack_send_message`, and kin) without the user's
explicit approval of that specific call.

**Joining mid-incident** (the common case): if response is already underway,
ask for or reconstruct what has happened so far; every pre-invocation timeline
entry is marked **inferred** unless corroborated by a log, deploy record, or
pasted message. Anchor the status-update cadence to now, not to onset.

## 1 — Severity and clock

Establish and state: what's firing, since when, and blast radius (customers
affected? money path? data at risk?). Propose a severity with the reasoning.
Escalation is time-boxed, not vibe-based — if severity implies a response SLA
the org defines (SEV1-style: minutes, not hours) and the right owner isn't
engaged, drafting the escalation ping is part of THIS step, not something
deferred until the investigation is tidy.

## 2 — Correlate (hypotheses, not a data dump)

The most common cause of a new alert is a recent change. Work the time-window
join, cheapest signal first:

1. **Deploys/merges**: what shipped to the affected service in the window
   before onset (`gh pr list --state merged`, deploy logs, release channel).
   A deploy 10 minutes before onset is the lead hypothesis until disproven.
2. **Config/flags**: feature-flag changes and config pushes in the same window.
3. **Logs**: first occurrence of the error signature — did it start abruptly
   (change-shaped) or grow (load/leak-shaped)? Pull the 3-5 log lines that
   prove it, not pages.
4. **Upstream/downstream**: is a dependency also degraded? Check the alert's
   service neighbors before blaming the alerting service itself.

Maintain 2-3 competing hypotheses with a confidence call on each. Every claim
in the timeline is labeled **verified** (you saw the log/metric/deploy) or
**inferred** — never mixed silently. It's fine to say "cause unknown; ruled
out X and Y."

## 3 — Timeline (running artifact)

Keep a timestamped timeline from the start — onset, detection, each finding,
each action anyone takes. UTC plus local time. This is the postmortem's raw
material; write it as you go, not from memory afterward.

## 4 — Communicate on a cadence

Status updates are drafted every ~15 minutes while severity warrants, in this
fixed three-field shape — even when the update is "no change":

```
Status: <investigating | mitigating | monitoring | resolved>
Impact: <who/what is affected, quantified if possible>
Actions: <what's being done right now, by whom, next checkpoint time>
```

Draft each update for the user to approve/post (or post via Slack tools only
after approval). Investigation depth never excuses a missed update — if the
user is heads-down, remind them the cadence is due. Suggest a separate
communicator when the incident is big enough that one person can't do both.

## 5 — Propose mitigation (never execute unbidden)

Each proposed mitigation states, together: the action, the evidence linking it
to the lead hypothesis, the pre-check to run first (e.g. "confirm connection
count before killing sessions"), the rollback path, and what should improve
within minutes if the hypothesis is right. No rollback path → say so
explicitly; that raises the approval bar, never lowers it.

## 6 — Handoff / wrap

On resolution or handoff, produce: final timeline, root-cause status
(confirmed / suspected / unknown), what mitigated it, follow-ups worth
ticketing (each one groomable via /ticket:groom), and any runbook gap this
incident exposed. Write it narrative-with-numbers style: quantified blast radius ("N incidents on M of K days; X of ~Y
sessions"), exact timestamps, and trace/session IDs, suitable for pasting
into the fixing PR's description.

## Quick checklist (mirrors the sections above)

1. Severity + blast radius stated; escalation drafted if SLA at risk
2. Deploys → flags → logs → dependencies correlated; hypotheses ranked
3. Timeline running, verified vs inferred labeled
4. 15-min status cadence, three fields, drafted for approval
5. Mitigations proposed with pre-check + rollback; user executes
6. Wrap: timeline, cause status, follow-up tickets, runbook gaps

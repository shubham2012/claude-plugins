# debug

Four skills covering the debugging lifecycle: live incident → reproduction →
flaky-test diagnosis → postmortem.

## /debug:triage `<incident id | alert text | symptom>`

On-call first response, **read-only by default**: severity and blast radius,
correlate the alert with recent deploys → flags → logs → dependencies (ranked
hypotheses, every claim verified or inferred), running timeline, status drafts
every ~15 minutes (Status / Impact / Actions). Mitigations are proposed with
pre-check + rollback and executed only on your per-action approval. Handles
joining mid-incident: reconstructed history is marked inferred.

## /debug:repro `<stack trace | error log | failure description>`

Production error → minimal failing test. Locates the trace in the repo, states
the trigger hypothesis, writes the test at the lowest layer that expresses it,
and verifies it fails **with the same error signature** as production. The
deliverable is the repro, not the fix — the test becomes the regression test
when the fix lands.

## /debug:flaky `<test name or path>`

Establishes the flake rate empirically (10-20 runs, race detector where
available), classifies the cause with `file:line` evidence (time / ordering /
shared state / concurrency / external), decides whether the bug is in the code
or in the test's contract, and proves the fix: 20 consecutive passes plus
re-inducing the flake on revert. Sleeps, retries, and tolerance-widening are
banned outcomes.

## /debug:rca `<timeline | links | description>`

The house postmortem: narrative with numbers (quantified blast radius,
timestamps, trace IDs), an evidence-anchored cause chain that stops where the
evidence stops, contributing factors separated from the root cause, and
follow-ups that each name whether they prevent, detect, or shrink — every one
groomable via /ticket:groom. Blameless; pastes cleanly into the fixing PR.

## Install

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install debug@claude-plugins
```

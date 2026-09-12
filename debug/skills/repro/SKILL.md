---
name: repro
description: Turn a production error — stack trace, log line, or incident finding — into a minimal failing test in this repo. The deliverable is the reproduction, not the fix. Use when the user pastes an error and wants it reproduced, or invokes /debug:repro.
argument-hint: <stack trace, error log, or description of the failure>
---

# Reproduce

Input: $ARGUMENTS (a stack trace, error text, or failure description). If
empty, ask for it and stop.

The deliverable is a **minimal failing test that fails with the same error
signature as production**. Do not fix the bug unless the user asks afterward —
a reproduction someone can run beats a fix nobody can verify.

## 1. Locate

Parse the trace/error to real code: grep the error string and walk the stack
frames to `file:line` in this repo. Read the full function(s) on the path, not
just the named lines. If the trace doesn't match current code (old deploy),
say so and identify the commit it does match (`git log -S`) before continuing.

## 2. Determine the trigger

From the code path, work out what input or state reaches the failing line:
nil/missing field, boundary value, ordering, concurrent access, external
response shape. State the trigger hypothesis in one sentence before writing
the test — if you can't, you don't understand the path yet; keep reading.

## 3. Write the minimal failing test

- At the lowest layer that can express the trigger: unit test if the logic is
  pure, integration test only when the failure lives at a boundary.
- Match the repo's existing test idioms and helpers — mirror a neighboring
  test file's structure.
- Name it after the behavior, and comment the production error it reproduces
  (link/ID, not prose).
- For suspected races: a concurrent test that fails reliably (loop it, use the
  race detector where the language has one) — a race repro that passes 9 of 10
  runs isn't a repro yet.

## 4. Verify it fails for the RIGHT reason

Run it. It must fail with the same error signature as production — a test
failing on a typo or setup error is not a reproduction. Show the failing
output. Then confirm the rest of the suite still passes (the repro must not
break unrelated tests).

## 5. Hand off

Report: trigger (one sentence), test location, the failing output, and the
suspected root cause with `file:line`. Offer next steps: fix it now, or
/ticket:groom it with the repro attached. The failing test stays — it becomes
the regression test when the fix lands (house rule: bug fixes ship with the
test that failed before them).

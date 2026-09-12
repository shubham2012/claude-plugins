---
name: flaky
description: Diagnose a flaky test — establish the flake rate, classify the cause (time, ordering, shared state, concurrency, external dependency), and fix the actual cause, never the symptom. Use when a test fails intermittently, CI is red on retries, or the user invokes /debug:flaky.
argument-hint: <test name or path>
---

# Flaky Test

Target: $ARGUMENTS. If empty, ask which test and stop.

Banned outcomes up front: adding sleeps, adding retries, widening tolerances,
skipping or deleting the test. Those convert a loud flake into a silent gap.

## 1. Establish the flake, don't assume it

Run the single test repeatedly (10-20 runs; use the repo's stress tooling if
it has one — `go test -count=`, `-race`, pytest `-x --count`, whatever
exists). Record the rate and the exact failure output. A test that fails 0/20
here but flakes in CI → the difference IS the lead (parallelism, resources,
ordering with other tests) — next, run it alongside its package/suite the way
CI does.

## 2. Classify the cause (evidence, not vibes)

Read the test AND the code under test. The classes, with what to grep for:

- **Time**: wall-clock reads, second-resolution truncation, timezone, TTLs
  (`time.Now`, `Date.now`, sleeps in test).
- **Ordering/determinism**: map iteration, unordered query results, ordering
  assumptions on concurrent completions (the house review theme: queries need
  a deterministic secondary sort key).
- **Shared state/isolation**: globals, shared fixtures/DB rows, leftover
  files, port collisions, tests mutating what parallel tests read.
- **Concurrency/race**: goroutines/threads finishing after asserts, missing
  synchronization — run with the race detector; a race-detector hit is the
  answer, stop classifying.
- **External dependency**: real network, real clock services, rate limits.

State the classification with the evidence line (`file:line`).

## 3. Decide where the bug is

A flaky test has exactly one of two problems: the production code is
nondeterministic where it shouldn't be (fix the code), or the test asserts
something the code never promised — e.g. equality across a time boundary
(fix the test's contract, and say the expectation was wrong). Name which one
this is. When it's the code, the fix follows house patterns: inject the
clock, add the sort key, synchronize the write — not test-side tolerance.

## 4. Prove the fix

The bar is the house exemplar: **20 consecutive passes** under the same
conditions that flaked (same parallelism, race detector on where available),
plus the failure mode re-inducible when the fix is reverted (revert, watch it
flake, restore — that proves you fixed the cause, not the weather). Show both.

## 5. Report

Rate before → after, class, root cause at `file:line`, which side (code vs
test contract) was wrong and why, and the proof runs. If other tests share
the same pattern (same global, same clock read), list them as follow-ups —
/ticket:groom material, not silent scope creep.

# Wording pass rules

Goal: remove ambiguity that costs correction rounds. Not style polish.

## Fix

- Grammar, spelling, and punctuation errors in prose.
- Wrong-word usage: their/there, affect/effect, imply/infer, and similar.
- Ambiguous pronouns — replace "it", "this", "that one" with the thing meant,
  when grounding (Stage 1) makes the referent certain. If uncertain, it becomes
  a question, not a guess.
- Vague request verbs → explicit action verbs. Models treat "can you suggest
  changes" as a request for suggestions, not changes. Rewrite intent-to-act
  prompts with imperative verbs:
  - "can you look at improving X" → "improve X" or "change X to ..."
  - "maybe we should handle errors" → "handle <specific error> in <place>"
- Negations that hide the real instruction → positive instructions:
  - "don't make it slow" → "keep <operation> under <bound>" (only if the bound
    is known or asked about; otherwise leave and raise a question).

## Never silently correct

Identifiers, filenames, flags, package names, repo names, env vars, make
targets, branch names. Internal names routinely look like typos and are not:
`utill.py`, `--force-colour`, `recieve_queue` may all be real. The rule:

- If grounding resolved the name exactly as written → keep it, it is correct.
- If grounding found a near-miss (`billing_serivce.py` vs `billing_service.py`
  both plausible) → open question with both options, never a correction.
- If grounding found nothing → keep as written, label `[unverified]`; if the
  name is load-bearing for the action, also raise a Stage 6 question asking for
  the correct path/name.

## Output

Every change listed as `before → after`, one per line, in the Corrections block.
No change is made that is not listed. If nothing changed: "no wording changes".

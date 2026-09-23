# PRD template (LLM-optimized)

Synthesized 2026-09-23 from the convergent mechanisms of spec-kit, Kiro, and
BMAD PRD templates plus Nirvana document style (narrative with numbers).
Omit any section with nothing real to say — an empty section is a defect.
Length scales to the ask; the Quick form is just sections 1, 3, 5, 6.

## Banned content (enforced at self-review)

- Implementation detail: tech stack, file paths as decisions, schema designs,
  "we will use X library". WHAT/WHY only — HOW is /build:hld's job.
- Vague verbs as requirements: "improve", "optimize", "better", "seamless",
  "appropriate". If it can't fail a test, it isn't a requirement.
- Unsourced claims stated as fact. Link it or mark `[unverified]`.

## Sections

### 1. One-liner
`<what we're building>, for <whom>, because <why now>.` One sentence. If this
can't be written, the PRD isn't ready to exist.

### 2. Problem & evidence
The user/business pain, with evidence: metrics, thread links, ticket links,
support volume. Numbers over adjectives ("~40 manual corrections/week" beats
"frequent errors").

### 3. Goals / Non-goals
Goals: 2-5, each measurable or observable. Non-goals: what an eager reader
would wrongly assume is included — name it to kill the assumption. The two
lists must not overlap.

### 4. Users & audience
Who uses it, who's affected, who must be informed. Skip entirely for
internal-only tooling with one obvious user group.

### 5. Requirements
Numbered, traceable, with EARS acceptance criteria:

```
FR-1: <requirement, one sentence>
  AC-1.1: WHEN <event/condition> THE SYSTEM SHALL <observable behavior>
  AC-1.2: IF <error/edge condition> THE SYSTEM SHALL <behavior>
NFR-1: <performance/reliability/compliance bound, with a number>
```

Every FR has ≥1 criterion someone could turn into a test. Downstream HLD and
spec reference these IDs — never renumber after publishing.

### 6. Success criteria & metrics
How we'll know it worked post-launch: target metrics with baseline and
timeframe, plus guardrail metrics that must NOT regress. Binary or numeric.

### 7. Dependencies & risks
Systems, teams, migrations, sequencing this needs — each verified (link,
`file:line`, owner) or `[unverified]`. Risks with a one-line mitigation each.

### 8. Open questions
Unresolved `[NEEDS CLARIFICATION]` items land here with owner + needed-by.
Visible is the point; an empty section here after one quiz round is normal.

### 9. References
PRD's evidence trail: threads, tickets, prior docs, research findings the
quiz contradicted (note the tension). Everything linked, nothing pasted.

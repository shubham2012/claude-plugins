# Generated-prose patterns

Each entry: what to look for, why it reads as machine-written, the fix, and
when to leave it alone. Families are ordered by how reliable the signal is.
**Strong** patterns justify an edit on a single sighting. **Weak** patterns
are things careful people also do; act on them only when other patterns
share the same passage.

The common root: a model picks the choice that suits the most readers, so
its prose emphasizes by formula, balances by formula, and pads to feel
complete. A person writes for one reader and makes uneven, specific
choices. Every fix below replaces a formula with the specific claim.

## A. Manufactured emphasis (strong)

### A1. Contrast against a claim nobody made
**Look for:** "X, not Y", "it's not X, it's Y", "not only X but also Y", "this isn't
about X", a two-sentence version ("That doesn't mean X. It means Y."), and a
trailing negative ("..., no manual steps").
**Why:** The rejected half exists to make the kept half feel bigger. It adds
weight, not information.
**Fix:** State Y. Keep a contrast only when readers actually believe X, or
when both halves carry a fact.
> Before: This isn't just a refactor. It's a rethink of how billing handles retries.
> After: The refactor changes how billing retries failed charges: it now backs off per customer instead of globally.

### A2. Punchline paragraphs and fragment runs
**Look for:** a paragraph of one sentence that repeats the previous one ("That's
the whole point."), an identical kicker ending section after section, a run of
fragments ("No locks. No races. No surprises."), spaced-out emphasis
("every. single. time.").
**Why:** It asks the reader to pause instead of giving them something new.
**Fix:** Cut closers that repeat. Fold fragments into one sentence that makes
a specific claim. Short sentences are fine if they tell the reader something new.
> Before: The worker now reads from the replica. No more lock contention. No more timeouts. Problem solved.
> After: The worker now reads from the replica, so it no longer contends for locks on the primary and the nightly timeouts stopped.

### A3. Aphorisms and "the real question"
**Look for:** "at its core", "what it really comes down to", "the real
question is", "fundamentally", noun-of-noun maxims ("trust is the currency
of collaboration"), and inverted epigrams ("speed without clarity is just
noise").
**Why:** An ordinary point gets dressed up as a hidden truth.
**Fix:** Replace the saying with the concrete claim it gestures at.
> Before: At its core, observability is the currency of trust between teams.
> After: Teams trust each other's services more when they can see the same dashboards during an incident.

### A4. Throat-clearing openers
**Look for:** "Let's dive in", "Let's unpack this", "Here's the thing",
"Here's everything you need to know", "Quick note:", a standalone "Honestly?" or
"Look," before a routine claim.
**Why:** It announces a point instead of making it.
**Fix:** Delete the run-up and start with the point. "Honestly" mid-sentence
in casual text is normal; the tell is the staged opener.
> Before: Let's unpack what changed. The key thing: the cache key now includes the tenant ID.
> After: The cache key now includes the tenant ID.

### A5. Rebutting an absent objection
**Look for:** "To be clear", "I'm not saying", "Don't get me wrong", "You might
think... but", "One might be tempted to", "The naive fix would be".
**Why:** Typically residue of a revision; it answers a point the text
never made.
**Fix:** Delete it. If there's a genuine claim buried inside, say that
directly. Keep a
rejected option a reviewer would genuinely propose, since explaining why it
was rejected is useful in design docs and PRs.
> Before: The obvious fix would be to just add a mutex, but that wouldn't scale. Instead we use an idempotency key.
> After: Charges carry an idempotency key, so a retried request can't double-charge.
> (Keep the mutex sentence if a reviewer is likely to ask "why not a lock?")

## B. Mechanical rhythm

### B1. Reflexive triples (weak alone)
**Look for:** lists of exactly three that don't need three ("faster, safer,
and more reliable"), three parallel sentences followed by a moral.
**Fix:** Keep the items that are distinct and true. Two is fine. Four is
fine. Keep three when there really are three.
> Before: The change improves performance, reliability, and developer experience.
> After: The change cuts p95 latency on /quotes from 800ms to 300ms.

### B2. Dashes as a universal joint (strong when frequent)
**Look for:** em dashes, en dashes, and ` -- ` used to join clauses.
**Rule:** Remove them from the final prose unless the voice sample or
`.claude/humanize.local.md` says the writer uses them; then match that rate.
Swap each for whatever punctuation says how the two clauses connect (full
stop, comma, colon, brackets), or restructure the sentence. Never touch dashes in code, commands, flags,
paths, URLs, or ranges like `2024–2025`.
> Before: The migration — which runs online — backfills the column.
> After: The migration runs online and backfills the column.

### B3. Same opener, sentence after sentence (weak alone)
**Look for:** three or more consecutive sentences starting with the same
word ("It", "This", "The service").
**Fix:** Merge, or lead with the action. Don't ban the word.

### B4. Qualifier stacking (weak alone)
**Look for:** "could potentially", "may possibly", "it's arguably possible
that", several hedges on one claim.
**Fix:** Keep one hedge if the doubt is real, none if it isn't. Keep genuine
uncertainty in RCAs and estimates; it's information.
> Before: This could potentially possibly cause some issues in certain edge cases.
> After: This can fail when two retries land in the same second.

### B5. Uniform bullets (weak alone)
**Look for:** every bullet the same length and grammatical shape,
especially one line each.
**Fix:** Let bullets be as long as their content. Merge thin ones; turn a
list of three one-liners into a sentence when it reads better.

## C. Inflation

### C1. Stock vocabulary (weak alone; strong in clusters)
**Look for:** delve, leverage (verb), seamless/seamlessly, robust
(figurative), comprehensive, crucial, pivotal, intricate, meticulous,
landscape (abstract), tapestry, testament, underscore/highlight (verbs),
foster, streamline, empower, elevate, holistic, synergy, cutting-edge,
game-changer, unlock, navigate (figurative), realm, embark, bolster,
ensure (as filler), key (adjective), notably, additionally.
**Why:** Models use these far more than people do, and they tend to arrive
in groups.
**Fix:** Use the plain word, or cut it if it adds nothing. Keep technical
senses: a "robust estimator", "leverage" in finance, "key" as in API key.
> Before: This PR leverages a robust, comprehensive approach to seamlessly streamline retries.
> After: This PR moves retries into one helper so every client backs off the same way.

### C2. Significance inflation
**Look for:** "marks a pivotal moment", "plays a key role", "sets the stage
for", "a testament to", "paves the way", closing "the future looks bright"
paragraphs, stock "Challenges" or "Looking ahead" sections with no content.
**Fix:** Keep the fact, drop the importance claim. Finish on something
concrete. If real follow-ups exist, list them as follow-ups.
> Before: This migration marks a pivotal step in our journey toward a more scalable platform.
> After: This migration moves quotes to Postgres. Policies follow in Q3 (ENG-4412).

### C3. Verb avoidance
**Look for:** "serves as", "acts as", "stands as", "functions as", "boasts",
"features", "offers" where "is" or "has" would do.
**Fix:** Use is, are, has.
> Before: The gateway serves as the single entry point and boasts built-in rate limiting.
> After: The gateway is the single entry point and has built-in rate limiting.

### C4. Decorative -ing tails
**Look for:** a clause ending in ", ensuring...", ", highlighting...",
", reflecting...", ", enabling..." that claims more than the sentence
proved.
**Fix:** Keep the fact. Keep the tail only if it's a real, supported
consequence; then make it its own clause.
> Before: We added a retry wrapper, ensuring resilience across all downstream services.
> After: We added a retry wrapper to the three clients that call Stripe.

### C5. Vague linkage
**Look for:** "associated with", "related to", "tied to", "in connection
with", where the relationship is known.
**Fix:** Name the relationship if the source gives it. If it doesn't, keep
the vague phrase rather than invent one.
> Before: The outage was related to the config change.
> After: The config change set the pool size to 0, which caused the outage.
> (Only if the source says so. Otherwise leave "related to".)

### C6. Unbacked authority and claims
**Look for:** "experts agree", "industry best practice", "widely
considered", "fully tested", "production-ready", "battle-tested", with no
evidence in the text.
**Fix:** Point to the evidence the source has (test names, a linked doc,
a metric). If there is none, cut the claim or turn it into a plain
statement of what was done. Never invent a citation, test, or number.
> Before: This change is fully tested and follows industry best practices.
> After: Added unit tests for the retry and timeout paths; ran the billing suite locally.
> (Only what actually happened. If you don't know, cut the sentence.)

## D. Decoration

### D1. Bold labels and bold sprinkles
**Look for:** every bullet starting with a bold label and colon, bold on
words with no reason to stand out.
**Fix:** Remove the bold. If the labels just repeat the bullet, write the
list as prose. Keep bold for one genuine warning, and for template field
names the document's format requires.
> Before: - **Performance:** Performance is improved. - **Security:** Security is enhanced.
> After: Queries use the new index, and tokens are now hashed at rest.

### D2. Heading décor
**Look for:** Title Case On Every Word, emojis or arrows in headings and
bullets, a horizontal rule between every section, a top heading that
repeats the title, headings on a document too short to need them.
**Fix:** Sentence case, no decoration, headings only where a reader will
navigate. Required template headings stay as they are.

### D3. Curly quotes (weak alone)
**Look for:** “curly” quotes in plain text, Markdown, or code-adjacent prose.
**Fix:** Straight quotes, unless the target format uses curly quotes.

## E. Residue

These are the most certain tells. Remove them outright.

### E1. Chat wrappers
**Look for:** "Great question!", "Certainly!", "Hope this helps!", "Feel free
to reach out", "Let me know if...", "Would you like me to...", "Here's a summary of...", "You're
absolutely right".
**Fix:** Delete the wrapper, keep the content.

### E2. Knowledge-limit hedges and gap-filling guesses
**Look for:** "as of my last update", "based on available information",
"details are limited", "likely", "it appears that" used to paper over a
missing fact.
**Fix:** Say plainly what isn't known, or cut the sentence. Never promote a
guess to a fact.
> Before: While the exact cause is not fully documented, it likely stemmed from a race condition.
> After: The cause isn't confirmed yet. The leading hypothesis is a race between the two workers.

### E3. Heading echo
**Look for:** a heading followed by a sentence that restates it ("##
Rollback / Rollback is important.").
**Fix:** Delete the echo.

### E4. Recap endings
**Look for:** "In summary", "To sum up", "Overall", a final paragraph that
restates the document.
**Fix:** Delete it, unless the document is long enough that a reader
would genuinely skip to the end (then make it a TL;DR at the top).

### E5. Narrating the previous version
**Look for:** code comments and docs that describe what used to be there
("Replaced the old O(n²) loop with..."), "now" and "new" in reference docs.
**Fix:** Describe current behavior. History belongs in commit messages,
changelogs, PR descriptions, and migration guides, where it's the point.
Keep a reference to the past when it justifies the present: a comment
saying the recursive version overflowed the stack on deep trees explains
why the code is iterative, and a future editor needs that.
> Before: // Changed to use a map instead of the old nested loop, which was slow.
> After: // Map lookup keeps this O(n); the input can be 50k rows.

## Leave these alone

- Anything inside quotes, titles, proper names, or text that discusses a
  phrase rather than using it.
- Letter salutations and sign-offs.
- Specific, odd, human details: an exact address, a strange quote, a
  one-off aside, a self-correction, mixed feelings stated honestly.
- Deliberate first-person phrasing that the author clearly chose.
- Genuine uncertainty. Hedges that carry real doubt are information.
- A single weak signal in otherwise clean text. Several signals together
  are the evidence; one is noise, and plenty of people write that way.

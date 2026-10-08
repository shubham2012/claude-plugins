# write

Prose editing for the text we produce every day: PR descriptions, commit
messages, specs, RCAs, Slack posts.

## /write:humanize `<text | file | PR>`

Edits a draft so it reads like a person explaining something to a
colleague. It removes the patterns that make generated prose easy to spot
(contrasts against claims nobody made, punchline closers, reflexive lists
of three, dashes everywhere, "leverage/robust/seamless", bold-label bullets,
"I hope this helps") and leaves every fact where it was.

```
/write:humanize <pasted text>
/write:humanize docs/rollout.md
/write:humanize 1234            # a PR in the current repo
/write:humanize                 # the latest draft in this conversation
```

Text in, text out: you get the rewrite in one copyable block plus a few
lines on what changed. For a file or a PR you see the changed passages
first, then choose **Apply / Show full text / Cancel**. Nothing is written
before you pick, and a typed reply amends the rewrite rather than applying
it.

It won't touch code, inline code, commands, paths, URLs, identifiers, log
lines, error strings, quoted text, or required template headings. It won't
add a fact or drop one: a claim like "fully tested" with nothing to back it
gets cut or reduced to what's known, and flagged under **Needs you** so you
can fill in the real detail. Text that's already clean comes back as
"Reads fine as is."

### Matching your voice

Paste a sample of your own writing with the request and it matches that
sample's sentence length, word choice, and punctuation, including dashes if
you use them. For a standing preference, add `.claude/humanize.local.md` to
a repo:

```markdown
## Voice sample
<a few paragraphs you wrote>

## Preferences
- Dashes: allowed, sparingly
- Allow: "leverage" (we mean financial leverage)
- Avoid: "utilize"
```

A sample in the conversation beats the local file, which beats the default
catalogue. Fact preservation beats all of them.

### Why it isn't read-only

The skill has no `allowed-tools` whitelist, because file and PR modes need
to write. The Apply gate is the safeguard instead: text mode never writes,
and file or PR mode writes only after an explicit Apply.

The pattern catalogue lives in `skills/humanize/references/patterns.md` and
is loaded only when the skill runs.

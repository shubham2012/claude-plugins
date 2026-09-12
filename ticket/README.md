# ticket

## /ticket:groom `<raw report>`

Turns a vague bug report, pasted thread, error output, or idea into a
well-formed tracker issue (Linear via MCP, or GitHub Issues via `gh`): extract-don't-invent, repo grounding of error strings
to `file:line`, duplicate check before drafting, symptom-vs-root-cause
classification (titles stay on the observable), binary acceptance criteria
("works properly" is banned), max three open questions with options.

Nothing is created until you pick `Create the issue` or `Create, I'll edit
first` — free-text answers amend the draft and re-gate, never create. When
no tracker is reachable (auth errors included), it hands you the copyable
draft instead.

## Install

```
/plugin marketplace add shubham2012/claude-plugins
/plugin install ticket@dev-workflows
```

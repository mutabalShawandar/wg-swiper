# .agents – shared team memory for agents

Agents on this project work as a team. This folder is how we avoid duplicate work and keep knowledge after a session ends. **Read `INDEX.md` before starting any task. Write an entry before finishing one.**

```
.agents/
├─ INDEX.md        # one line per entry, maintained by the orchestrator
├─ features/       # new capabilities: what exists, where, how to use it
├─ changes/        # refactors, config, infra, dependency or schema changes
├─ fixes/          # bugs found + root cause + fix (so they are not reintroduced)
├─ guides/         # how-to: run, test, debug, conventions, gotchas
├─ decisions/      # why X over Y (short ADRs)
└─ templates/entry.md
```

## Rules
1. **Before starting:** read `INDEX.md`, open entries related to your area, and check open PRs (`gh pr list`) for overlap. Reuse what exists; do not rebuild it. If you find overlap or a conflict with another agent, stop and tell the orchestrator.
2. **Before finishing:** add exactly one entry file (more for separate guides) using `templates/entry.md`. File name: `YYYY-MM-DD-<branch-slug>.md`. It is committed on your branch and is part of your PR. The security reviewer checks it too (no secrets, no real keys).
3. **Never edit `INDEX.md` in a task branch.** The orchestrator adds the line when merging, so parallel branches never conflict.
4. **Be honest.** List what was not done, not run, or not verified (e.g. "no simulator run"). Future agents trust these notes.
5. **Keep it short and factual**: paths, commands, contracts. No chat logs, no secrets, no personal data.
6. If an old entry is wrong or outdated, fix it in your branch and say so in the PR (entries are living docs, not history).
7. Handoffs between teammates go through the orchestrator, but the facts they need live here.

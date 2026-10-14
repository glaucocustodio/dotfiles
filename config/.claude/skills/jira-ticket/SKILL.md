---
name: jira-ticket
description: Create a Jira ticket on the OI (Order Integrations) board, written so any business stakeholder can understand it.
invoke: when the user asks to create, open or file a Jira ticket / issue / bug
permissions:
  allowed_commands:
    - git branch
    - git log
    - git status
    - git commit
    - git push
    - gh pr
---

Create a Jira issue on the **OI** board, then offer to stamp its ID onto the branch's last commit.

## Board facts

| | |
|---|---|
| Site (`cloudId`) | `easyship-team.atlassian.net` |
| Project key | `OI` — Order Integrations |
| Board | https://easyship-team.atlassian.net/jira/software/c/projects/OI/boards/120 |
| Issue types | `Bug`, `Task`, `Story`, `Epic`, `Sub-task` |
| Lands in | `Backlog` |

Create with `mcp__claude_ai_Atlassian_Rovo__createJiraIssue`, passing `contentFormat: "markdown"`.
Get the reporter's account id from `mcp__claude_ai_Atlassian_Rovo__atlassianUserInfo` and assign the
ticket to them unless the user names someone else.

## Choosing the issue type

Infer the type from what the feature branch actually changes. Do not ask first — look.

```
git diff origin/<base>...HEAD --stat
git diff origin/<base>...HEAD --name-status
git log origin/<base>..HEAD --format='%s'
```

Use `origin/<base>` rather than the local branch, which is often stale. Read the signals together
and let the code outweigh the wording:

| Signal | Type |
|---|---|
| Corrects behaviour that was already meant to work; commit subject starts `fix` or `hotfix` | `Bug` |
| Adds capability a user or API consumer can observe — new endpoint, field, screen, flow; subject starts `feat` | `Story` |
| Dependency bumps, config, CI, build, tooling, refactors, spec-only changes; subject starts `chore`, `build`, `ci`, `refactor`, `test`, `docs`, `perf`, `style` | `Task` |
| Large enough that it needs breaking into separate tickets | `Epic` |

When signals disagree, the diff wins over the commit subject — a subject typed `chore` that in fact
repairs broken behaviour is still a `Bug`.

Ask the user only when inference genuinely fails: the branch has no commits over its base, the tree
is clean with nothing to inspect, the work is not on a branch at all, or the changes point two ways
at once. When you do ask, say what you found and which types are in play, rather than asking cold.

## Write it for the business, not for engineers

This is the part that matters most. The reader is a product manager, a support lead, or an
account manager. They must be able to tell, without help, **what is wrong, who it hurts, and what
changes when it is fixed.** Someone skimming the backlog should grasp the ticket in one read.

So:

- Lead with the human consequence, not the mechanism. "Merchants on the Shopify integration see
  duplicate orders" — not "the webhook handler lacks an idempotency key".
- Name the affected group and the blast radius: which merchants, which couriers, how many, how
  often. If it only affects developers locally, say exactly that — it sets expectations about
  urgency more than any severity field will.
- Say what "done" looks like in observable terms.
- Prefer plain words: "fails to save" over "raises `ActiveRecord::RecordInvalid`".
- No file paths, no line numbers, no stack traces, no log excerpts, no code blocks in the main body.
- Spell out an acronym the first time unless it is already everyday language in the business.

The body has these sections, in this order (all required except Technical Notes):

```
## Context
## Problem
## Goal
## Definition of Done
## Technical Notes
```

- **Context**: the background a reader needs first: which feature, integration or flow this is
  about, and which merchants, couriers or teams use it.
- **Problem**: what is wrong or missing today, who it hurts and how badly (the blast radius: how
  many, how often). For a `Story` or `Task`, the gap or limitation that motivates the work.
- **Goal**: what changes once the work is done, in business terms.
- **Definition of Done**: a checklist (`- [ ]`) of observable outcomes someone outside engineering
  could verify. Not implementation steps.
- **Technical Notes**: the only section where file paths, commands, error strings or code blocks may
  appear. Keep it short: a reproduction case, the exact error, the suspected area of code. When there
  is nothing worth adding, omit the section entirely; that is the normal, healthy case, not an
  omission.

Link the PR if one exists. A URL is not "technical detail" and belongs in Context or Goal.

## Then offer the commit stamp

After the ticket is created, report its key and URL, then **ask** — do not act unprompted — whether
to put the ticket ID into the branch's last commit, using AskUserQuestion. Show the exact before and
after subject so the choice is concrete:

```
before:  build(docker): forward the Sidekiq Pro credential to the compose build
after:   build(OI-1175): forward the Sidekiq Pro credential to the compose build
```

Skip the offer entirely when it cannot apply: the branch is `develop`, `main` or `master`; the
working tree has the relevant change uncommitted; or the last commit is unrelated to this ticket.
Say why you are skipping rather than staying silent.

If the user accepts:

1. Amend the subject's scope to the ticket ID, leaving body and footer untouched. Follow the
   `commit` skill's format rules — the subject stays 72 characters or fewer, and never type the
   `(#NNNN)` suffix.
2. If the branch is already on the remote, `git push --force-with-lease`. Never `--force`, and
   never force-push `develop`, `main` or `master`.
3. If a PR is open for the branch, update its title to match the new subject
   (`gh pr edit <n> --title ...`), and verify the PR's head SHA now equals the amended commit.

Renaming the branch to carry the ticket ID is **not** part of this. Under an open PR it means
deleting and recreating the head ref, which GitHub can read as the branch disappearing and may close
the PR. Mention it as something to get right on the next branch instead.

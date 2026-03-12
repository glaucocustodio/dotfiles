---
name: daily
description: creates a daily status message based on recent user activity
invoke: when the user requests for their daily status
permissions:
  allowed_commands:
    - git log
    - gh pr list
    - gh pr view
---

Generate a daily status message based on user's activity on the following platforms:

- GitHub (commits, PRs, code review): try using github mcp, otherwise use the `gh` CLI command to fetch activity
- Slack (exchanged messages)
- Google Calendar
- Notion
- Sentry

- Refer to `examples.md` for concrete examples

## Format
```
:heavy_check_mark: What you worked on yesterday?
<yesterday_activity>

:crossed_fingers: What are you going to work on today?
<today_activity>

:sleeping: Anything waiting for review? or blocking you?
<blockers_and_anything_else>
```

## Rules

- Use the emoji :heavy_check_mark:, not :white_check_mark: for describing tasks worked yesterday
- Return links as plain text, not as markdown: "https://github.com/zipchat-ai/chatlive/pull/1119" not "#1119"
- Always use bullet points to describe tasks, first letter lowercase, no periods at the end
- When mentioning a GitHub PR or Notion page, include a link for it
- Only list the tasks the user worked on, not how it was resolved: "investigated escalation email delivery issue" not "investigated escalation email delivery issue (emails going to internal support instead of customer)"
- Use imperative, past tense for items worked on the day before: "Added feature" not "Add feature"
- Use imperative, present tense for items the user will work today: "Add feature" not "Added feature"
- Under `<blockers_and_anything_else>`, include PRs that are open and waiting for review (have reviewers assigned to it). Include anything that might be blocking the user and any time slot the user will be off for a doctor appointment or similar.
- NEVER use destructive commands on GitHub or Slack

For tasks related to the `#tech-support` Slack channel, group them under the `- tech-support:` bullet point, eg:

```
:heavy_check_mark: What you worked on yesterday?
- tech support:
  - fixed rating icon not updating in conversation view via Turbo
  - handled Sendgrid account under review
```

## Confirmation

Always ask for user review/confirmation. Once user is happy, send the message on the `#daily-updates` Slack channel.

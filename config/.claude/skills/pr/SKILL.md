---
name: pr
description: Open a PR on GitHub
invoke: when user ask to open a pull request
permissions:
  allowed_commands:
    - git push
    - gh
---

Push the current branch to remote and open a PR on GitHub.

If user is on branch `master`/`main`, show a error message instead.

If the repo contains a .github/PULL_REQUEST_TEMPLATE.md file, you should follow it, answering all questions asked.

If there is only one commit on the branch, use the first line of the commit message as PR title and the subsequent lines as `description` section of the PR template.

You can use the `gh` CLI for creating a PR on GitHub.

**NEVER** use ANSI escape codes for terminal colors or any other special codes, PR description should be plain text
**NEVER** push force to branch `master`/`main`

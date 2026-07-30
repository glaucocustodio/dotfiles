---
name: qa
description: Review code changes to ensure nothing breaks (no regression has been introduced)
invoke: when user asks for reviewing/QA changes
---

Review changes on this branch and try to find a case where it would break.

Suggest automated tests whenever possible.

Rank items by this order:

1- issues that might happen with the code as is (high relevancy)
2- issues that could happen once the current code gets changed (low relevant)

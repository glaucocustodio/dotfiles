# Examples

Note: none of these show the `(#NNNN)` PR-number suffix. GitHub appends it automatically when the
PR is squash-merged — never type it yourself.

**Simple fix, Jira scope, co-authored by AI**:

```
fix(COUR-3958): use item origin country for SF Express SourceArea field

SourceArea was hardcoded to "US" for all items. It now reads from the
shipment item's origin country, falling back to the shipment origin
country, consistent with the other courier integrations.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

**Commit containing many changes**:

```
feat(CORE-2691): block new Bulgaria signups on the dashboard

- reject Bulgaria as a company country during registration
- surface a clear message pointing affected merchants at support
- add rake tasks to deactivate and reactivate existing companies
```

```
chore(CORE-1379): prepare the app for the Rails 7.2 upgrade

- upgrade to puma 6, the default in rails 7.2
- remove config deprecated by the new framework defaults
```

**Breaking change**:

```
feat!(CORE-2691): drop legacy rate response fields

- remove the deprecated total_charge key from the rates payload

BREAKING CHANGE: total_charge is gone from /api/v1/rates. Clients must
read total_charge_amount instead.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```

**No Jira ticket available — fall back to a feature-name scope**:

```
chore(specs): remove the flaky courier rate timeout spec

The spec depended on wall-clock timing and failed intermittently on CI
without indicating a real regression.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```

**Optional Jira footer, for when the page adds context beyond the ticket ID**:

```
feat(FS-3485): refresh HS codes and prune the ones no longer published

- pull the latest published code list on a weekly schedule
- mark codes missing from the new list as inactive rather than deleting

Refs: https://easyship-team.atlassian.net/browse/FS-3485
```

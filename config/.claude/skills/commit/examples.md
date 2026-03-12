# Examples

**Simple fix co-authored by AI**:

```
Fix rating icon not updating in conversation view via Turbo

The turbo stream was only replacing the chat preview frame (:message_rate),
leaving the conversation detail and list rating icons stale after submitting a rating.

Co-authored-by: Claude Sonnet 4.6 <noreply@anthropic.com>
```

**Commit containing many changes**:

```
Add exit intent banner and fix tests

- add exit intent banner when merchant has checkout script installed
- fix flaky test
```

```
Prepare app for Rails 7.2 upgrade

- upgrade to puma 6 (default in rails 7.2)
- remove deprecated config
```

**Feature with AI attribution and Notion link**:
```
Add new flag remove_email_branding

- Add migration to add remove_email_branding boolean to users table
- Expose field in Admin -> Users section alongside Remove Branding
- Use remove_email_branding in customer mailer to control email footer branding

Notion: https://www.notion.so/zipchat/Remove-Sent-via-Zipchat-on-emails-31e71caef48b80099183db4e90375972

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

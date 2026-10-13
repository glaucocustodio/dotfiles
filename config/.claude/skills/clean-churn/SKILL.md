---
name: clean-churn
description: Detect and discard irrelevant working-tree churn — regenerated annotations, schema.rb column reordering, Postgres deparse differences — without ever touching real code changes.
invoke: when the user asks to restore, drop, clean or ignore irrelevant/noise/ordering-only changes
permissions:
  allowed_commands:
    - git diff
    - git status
    - git apply
    - git stash
---

Classify every modified file as **churn** or **real**, report the split, then discard only the
churn. Never guess: a file is churn only if a mechanical check proves it.

Discard with `git stash`, never `git restore`: a stash can be popped back, a restore cannot. Run
the backup, its verification and the stash as **separate commands** (steps 3–5), so a refusal of
one never takes the others down with it.

## What counts as churn

**A. Regenerated annotation blocks** — `annotaterb` rewrites the schema comment block at the top of
models, factories and specs on every `db:migrate`. The column order it emits follows the *local*
DB's physical order, which differs from CI's (CI builds with `db:schema:load`, dev DBs are restored
from a production dump). The output is noise, not truth.

**B. `db/schema.rb` reordering** — the same column-order divergence, plus Postgres re-rendering
stored index and view expressions with its own deparser. Equivalent forms that flip-flop between
Postgres patch releases:

    date_part('epoch'::text, X)          <->  EXTRACT(epoch FROM X)
    ARRAY[(a)::text, (b)::text]          <->  ((ARRAY[a, b])::text[])

**C. Any pure permutation** — the set of removed lines equals the set of added lines.

## What is NOT churn

- Any changed line that is not a comment, in a file whose diff should be comment-only.
- A changed `version:` line in `db/schema.rb` — that means a migration was added. Stop and say so.
- A new or dropped column, index, table or view in `db/schema.rb`.
- Config, Dockerfile, compose, CI or `.env*` edits. These are deliberate, however small.
- Staged changes and untracked files. Only ever act on unstaged modifications to tracked files.

## Procedure

**1. Prove each annotated file is comment-only.** Zero means churn; anything else means real code
is mixed in, so leave the file alone:

    for f in $(git diff --name-only -- 'app/models/**' 'spec/**'); do
      n=$(git diff -U0 -- "$f" | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -cv -E '^[+-]\s*#')
      [ "$n" != "0" ] && echo "REAL: $f ($n code lines)"
    done

**2. Prove `db/schema.rb` is a pure permutation.** Compare the removed and added line multisets;
empty output means pure reordering:

    d=$SCRATCHPAD; git diff -U0 -- db/schema.rb | grep '^-' | grep -v '^---' | sed 's/^-//' | sort > $d/a
    git diff -U0 -- db/schema.rb | grep '^+' | grep -v '^+++' | sed 's/^+//' | sort > $d/b
    diff $d/a $d/b

Non-empty residue is not automatically real — check it against the deparse pairs above first. Only
treat it as a real schema change if it survives that.

**3. Back up the churn — its own command.** Write the proven-churn path list, then a patch of just
those paths. Exclude real files and any file with staged changes (`git diff --cached --name-only`),
since stashing a path also takes its staged hunks. zsh does not word-split unquoted expansions, so
feed paths through `xargs` rather than expanding a variable:

    d=$SCRATCHPAD; ts=$(date +%s)
    git diff --name-only | grep -vxE '<real files>|<files with staged changes>' > $d/churn-files-$ts
    xargs git diff -- < $d/churn-files-$ts > $d/churn-$ts.patch
    echo $d/churn-files-$ts $d/churn-$ts.patch

Shell variables do not survive between commands, so use the literal paths this prints from here on.

**4. Verify the backup — its own command.** The patch must be non-empty and must reverse-apply
cleanly onto the current tree; that proves it can recreate exactly what is about to be stashed:

    test -s <patch> && git apply --check --reverse <patch> && echo BACKUP OK

Do not go on to step 5 unless this prints `BACKUP OK`.

**5. Stash the churn — its own command.** Stash only the listed paths, with a message that names
the backup, then confirm the stash exists and the paths are clean:

    xargs git stash push -m "clean-churn <ts>" -- < <churn-files>
    git stash list | head -1
    git diff --name-only

If this command is refused, stop: the backup from step 3 is intact. Give the user the exact
`! xargs git stash push -m "clean-churn <ts>" -- < <churn-files>` line to run themselves.

**6. Report.** State how many files were discarded, which were kept and why, the stash entry
(`stash@{0}: clean-churn <ts>`) and the backup patch path. Tell the user `git stash pop` brings the
churn back, and `git stash drop stash@{N}` removes it for good once they are satisfied.

## Mixed files

If one file has both churn and real changes, do not stash it. Say which hunks look like churn and
let the user drop them with `git restore -p` or stage selectively with `git add -p`.

## Prevention worth mentioning once

`ANNOTATERB_SKIP_ON_DB_TASKS=1` in the gitignored `.env` stops category A at the source — the guard
is in `lib/tasks/annotate_rb.rake`. Verify it actually loads (`Dotenv.parse(".env")` must list the
key) rather than assuming. It does not stop category B: `db:migrate` always re-dumps `schema.rb`
unless `config.active_record.dump_schema_after_migration = false` is set for development.

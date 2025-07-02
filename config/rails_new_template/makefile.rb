MAKEFILE_CONTENT = <<-CODE
run:
  bin/rails server

test:
  bundle exec rspec

console:
  bin/rails console

db_console:
  bin/rails dbconsole

dbconsole: db_console

lint:
  bundle exec standardrb --format progress

lint_fix:
  bundle exec standardrb --fix --format progress
CODE

def replace_spaces_by_tab_in_makefile
  # replace 2 spaces at the start of lines with a tab (\t) in Makefile
  run "sed 's/^  */\t/' Makefile > tmp_file && mv tmp_file Makefile"
end
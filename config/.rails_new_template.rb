# this file is triggered when `rails new` is run, check ~/.railsrc file
#
# see documentation at https://guides.rubyonrails.org/generators.html

gem "haml-rails"
gem "dotenv"
gem "faraday"

gem_group :development, :test do
  gem "amazing_print"
  gem "faker"
  gem "factory_bot_rails"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "standard"
  gem "standard-rails"
end

after_bundle do
  run "echo '############################# ℹ️  executing commands from .railsrc template #############################'"
  generate "rspec:install"

  file 'Makefile', MAKEFILE_CONTENT
  # replace 2 spaces at the start of lines with a tab (\t) in Makefile
  run "sed 's/^  */\t/' Makefile > tmp_file && mv tmp_file Makefile"

  append_to_file '.gitignore', GITIGNORE_CONTENT
  file '.standard.yml', STANDARD_CONFIG_CONTENT
  file '.rubocop.yml', RUBOCOP_CONFIG_CONTENT
  run "cp ~/.editorconfig .editorconfig"

  remove_file '.rspec'
  file '.rspec', RSPEC_CONFIG_CONTENT

  add_prepared_statements_comment_to_database_yml

  rails_command("db:create")

  git add: "."
  git commit: "-a -m 'create project'"
end

MAKEFILE_CONTENT = <<-CODE
run:
  bin/rails server

test:
  bundle exec rspec

console:
  bin/rails console

lint:
  bundle exec standardrb --format progress

lint_fix:
  bundle exec standardrb --fix --format progress
CODE

GITIGNORE_CONTENT = <<-CODE
.tags*
CODE

STANDARD_CONFIG_CONTENT = <<-CODE
---
plugins:
  - standard-rails
CODE

RUBOCOP_CONFIG_CONTENT = <<-CODE
# disable all cops by default so editors only show errors from standard
AllCops:
  DisabledByDefault: true
  SuggestExtensions: false
CODE

RSPEC_CONFIG_CONTENT = <<-CODE
--require rails_helper
CODE

def add_prepared_statements_comment_to_database_yml
  system(%q{
    file="config/database.yml"
    comment="# prepared_statements: false to simplify debugging"
    if ! grep -Fxq "$comment" "$file"; then
      { echo "$comment"; cat "$file"; } > "$file.tmp" && mv "$file.tmp" "$file"
    fi
  })
end

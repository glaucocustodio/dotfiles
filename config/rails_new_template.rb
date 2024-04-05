# this file is triggered when `rails new` is run, check ~/.railsrc file
#
# see documentation at https://guides.rubyonrails.org/generators.html

gem "haml-rails"
gem "dotenv-rails"
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
  run "cp ~/.editorconfig .editorconfig"
  # remove_file '.rspec'
  # file '.rspec', RSPEC_CONFIG_CONTENT

  rails_command("db:create") if yes?("Create database?")

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

RSPEC_CONFIG_CONTENT = <<-CODE
--require rails_helper
CODE

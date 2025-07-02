# this file is triggered when `rails new` is run, check ~/.railsrc file
#
# see documentation at https://guides.rubyonrails.org/generators.html
# https://adbatista.github.io/2025/05/25/templates.html

$app_name = app_name

require "~/rails_new_template/gems"
require "~/rails_new_template/makefile"
require "~/rails_new_template/readme"
require "~/rails_new_template/database"
require "~/rails_new_template/gitignore"
require "~/rails_new_template/standard"
require "~/rails_new_template/rubocop"
require "~/rails_new_template/rspec"
require "~/rails_new_template/factory_bot"
require "~/rails_new_template/webmock"
require "~/rails_new_template/stub_env"
require "~/rails_new_template/request_helpers"

# skip if generating a mountable engine with `rails plugin new foo --mountable` for example
return if options["mountable"]

install_gems(options)

after_bundle do
  run "echo '############################# ℹ️  executing commands from .railsrc template #############################'"
  generate "rspec:install"

  file 'Makefile', MAKEFILE_CONTENT
  replace_spaces_by_tab_in_makefile

  create_file 'README.md', README_CONTENT, force: true
  create_file 'config/initializers/database_cli.rb', DATABASE_CLI_CONTENT, force: true

  append_to_file '.gitignore', GITIGNORE_CONTENT

  file '.standard.yml', STANDARD_CONFIG_CONTENT
  file '.rubocop.yml', RUBOCOP_CONFIG_CONTENT
  run "cp ~/.editorconfig .editorconfig"

  add_prepared_statements_to_database_yml

  create_file '.rspec', RSPEC_CONFIG_CONTENT, force: true
  create_file 'spec/support/factory_bot.rb', FACTORY_BOT_CONFIG_CONTENT
  create_file 'spec/support/stub_env.rb', STUB_ENV_CONFIG_CONTENT
  create_file 'spec/support/request_helpers.rb', REQUEST_HELPERS_CONTENT
  prepend_to_file 'spec/spec_helper.rb', WEBMOCK_CONFIG_CONTENT
  uncomment_lines 'spec/rails_helper.rb', /Rails\.root\.glob\(.*support.*\.rb.*require f/
  add_aggregate_failures_to_spec_helper

  rails_command("db:create")

  git add: "."
  git commit: "-a -m 'create project'"
end

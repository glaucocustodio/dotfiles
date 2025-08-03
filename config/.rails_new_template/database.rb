DATABASE_CLI_CONTENT = <<-CODE
Rails.application.configure do
  config.active_record.database_cli = {postgresql: "pgcli"} if Rails.env.local?
end
CODE

def add_prepared_statements_to_database_yml
  insert_into_file 'config/database.yml', "\n  prepared_statements: false", after: "database: #{$app_name}_development"
end

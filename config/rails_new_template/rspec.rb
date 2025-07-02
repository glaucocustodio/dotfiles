RSPEC_CONFIG_CONTENT = <<-CODE
--require rails_helper
CODE

def add_aggregate_failures_to_spec_helper
  insert_into_file 'spec/spec_helper.rb', <<-CODE, after: "RSpec.configure do |config|\n"
  # https://rspec.toolboxforweb.xyz/docs/rspec-core/expectation_framework_integration/aggregating_failures
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
  CODE
end

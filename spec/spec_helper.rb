# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/inat-get/app/core/"  # Worker, Server — группа 3

  add_group "DSL", "lib/inat-get/data/dsl"
  add_group "Parsers", "lib/inat-get/data/parsers"
  add_group "Helpers", "lib/inat-get/data/helpers"
  add_group "Models", "lib/inat-get/data/models"

  minimum_coverage_by_file 1
end

require "bundler/setup"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  config.order = :random
  Kernel.srand config.seed
end

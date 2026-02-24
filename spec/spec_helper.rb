# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/inat-get/app/core/"  # Worker, Server — группа 3

  add_group "DSL", "lib/inat-get/data/dsl"
  add_group "Parsers", "lib/inat-get/data/parsers"
  add_group "Helpers", "lib/inat-get/data/helpers"
  add_group "Models", "lib/inat-get/data/models"

  # minimum_coverage_by_file 1
end

require "bundler/setup"

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end

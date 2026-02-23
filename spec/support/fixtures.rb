# frozen_string_literal: true

module FixtureHelpers
  FIXTURES_DIR = File.expand_path("../fixtures/api", __dir__)

  def api_fixture(path)
    full_path = File.join(FIXTURES_DIR, "#{path}.json")
    raise "Fixture not found: #{path}" unless File.exist?(full_path)

    JSON.parse(File.read(full_path), symbolize_names: true)
  end

  def api_results(path)
    data = api_fixture(path)
    data[:results] ? data : { results: [data], total_results: 1 }
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end

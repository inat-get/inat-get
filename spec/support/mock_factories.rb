# frozen_string_literal: true

module MockFactories
  def mock_model(name = :Observation, **overrides)
    helper = overrides.delete(:helper) || minimal_helper

    double("#{name}Model",
           helper: helper,
           **overrides)
  end

  def mock_helper(cls = INatGet::Data::Helper::Observations)
    helper = cls.instance
    allow(helper).to receive(:manager).and_return(mock_manager)
    helper
  end

  def mock_manager
    double("Manager",
           endpoint: :observations,
           parser: mock_parser,
           updater: mock_updater)
  end

  def mock_parser
    double("Parser", parse!: nil, fake: nil)
  end

  def mock_updater
    double("Updater", update!: nil)
  end

  def minimal_helper
    double("MinimalHelper",
           prepare_query: { normalized: true },
           query_to_api: { api: true },
           query_to_sequel: Sequel.lit("true"),
           validate_query!: true)
  end
end

RSpec.configure do |config|
  config.include MockFactories
end

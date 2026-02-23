# frozen_string_literal: true

module SequelMockHelpers
  def mock_db
    Sequel.mock
  end

  def match_sql(dataset, *fragments)
    sql = dataset.sql
    fragments.each do |f|
      expect(sql).to include(f)
    end
  end

  def mock_dataset(table_name = :observations)
    db = mock_db
    db.from(table_name)
  end
end

RSpec.configure do |config|
  config.include SequelMockHelpers
end

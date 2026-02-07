# frozen_string_literal: true

require 'date'

require_relative '../../info'
require_relative 'conditions'

module INatGet::Data; end

module INatGet::Data::DSL

  private

  # @group System Info

  # @return [Date]
  def today
    Date.today
  end

  # @return [Time]
  def now
    Time.now
  end

  # @return [String]
  def version
    INatGet::Info::VERSION
  end

  # @endgroup

end

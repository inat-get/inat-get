# frozen_string_literal: true

require 'set'

require_relative '../../info'

module INatGet::Data; end
class INatGet::Data::Helper; end

# @api private
class INatGet::Data::Helper::Field

  # @return [Symbol]
  attr_reader :key

  # @return [INatGet::Data::Helper]
  attr_reader :helper

  def initialize helper, key
    @helper = helper
    @key = key
  end

  # @return [Boolean]
  def valid? value
    raise NotImplementedError, "Not implemented method 'valid?' for abstract class", caller_locations
  end

  # @return [Hash, Object]
  def prepare value
    value
  end

  # @return [Hash, Object]
  def to_api value
    value
  end

  # @return [Sequel::SQL::Expression]
  def to_sequel value
    { @key => value }
  end

end

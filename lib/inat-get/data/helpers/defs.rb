# frozen_string_literal: true

require 'set'

require_relative '../../info'

module INatGet::Data; end
class INatGet::Data::Helper; end

# @api private
class INatGet::Data::Helper::Field

  # @return [Symbol]
  attr_reader :key

  def initialize key
    @key = key
  end

  # @return [Boolean]
  def valid? value
    raise NotImplementedError, "Not implemented method 'valid?' for abstract class", caller_locations
  end

  # @return [Hash, Object]
  def prepare value
    # Преобразует значние в нормализованное. Или в Hash с нормализованными значениями.
    raise NotImplementedError, "Not implemented method 'prepare' for abstract class", caller_locations
  end

  # @return [Hash, Object]
  def to_api value
    raise NotImplementedError, "Not implemented method 'to_api' for abstract class", caller_locations
  end

  # @return [Sequel::SQL::Expression]
  def to_sequel value
    raise NotImplementedError, "Not implemented method 'to_sequel' for abstract class", caller_locations
  end

end

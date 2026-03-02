# frozen_string_literal: true

require 'set'

require_relative '../defs'

class INatGet::Data::Helper::Field::Set < INatGet::Data::Helper::Field

  def initialize helper, key, check
    super helper, key
    @check = check
  end

  def valid? value
    return true if value.nil?
    return true if @check === value
    if value.is_a?(Enumerable)
      value.each do |v|
        next if @check === v
        return false
      end
      return true
    end
    return false
  end

  def prepare value
    case value
    when nil
      nil
    when Enumerable
      value.to_set
    when @check
      ::Set[ value ]
    else
      raise ArgumentError, "Invalid field value: #{ @key } => #{ value.inspect }", caller_locations
    end
  end

end

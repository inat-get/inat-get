# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Helper::Field::Range < INatGet::Data::Helper::Field

  def initialize helper, key, check
    super helper, key
    @check = check
  end

  def valid? value
    @check === value || (Range === value && (value.begin.nil? || @check === value.begin) && (value.end.nil? || @check === value.end))
  end

  def prepare value
    case value
    when nil
      nil
    when Range
      value
    when @check
      (value .. value)
    else
      raise ArgumentError, "Invalid field value: #{ @key } => #{ value.inspect }", caller_locations
    end
  end

end

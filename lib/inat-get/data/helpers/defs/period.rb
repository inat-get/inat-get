# frozen_string_literal: true

require 'date'

require_relative 'range'

class INatGet::Data::Helper::Field::Period < INatGet::Data::Helper::Field::Range

  def initialize helper, key
    super helper, key, DateTime
  end

  def valid? value
    value.is_a?(DateTime) ||
      value.is_a?(Date) ||
      value.is_a?(::Range) && 
        (value.begin.nil? || value.begin.is_a?(DateTime) || value.begin.is_a?(Date)) &&
        (value.end.nil?   || value.end.is_a?(DateTime)   || value.end.is_a?(Date))
  end

  def prepare value
    (value_begin(value) .. value_end(value))
  end

  def to_api value
    result = {}
    case @key
    when :observed
      result[:d1] = value.begin if value.begin
      result[:d2] = value.end   if value.end
    when :created
      result[:created_d1] = value.begin if value.begin
      result[:created_d2] = value.end   if value.end
    end
    result
  end

  private

  def value_begin value
    value = value.begin if value.is_a?(::Range)
    value = value.to_datetime if value.is_a?(Date)
    value
  end

  def value_end value
    value = value.end if value.is_a?(::Range)
    value = (value + 1).to_datetime if value.is_a?(Date)
    value
  end

end

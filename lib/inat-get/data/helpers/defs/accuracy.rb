# frozen_string_literal: true

require_relative 'range'

class INatGet::Data::Helper::Field::Accuracy < INatGet::Data::Helper::Field::Range

  def initialize helper, key
    super helper, key, Integer
  end

  def to_api value
    result = {}
    if value.begin && value.begin > 0
      result[:acc_above] = value.begin
    end
    if value.end
      if value.begin
        result[:acc_below] = value.end
      else
        result[:acc_below_or_unknown] = value.end
      end
    end
    result
  end

  def to_sequel value
    return {} if valid.nil? || (value.begin.nil? && value.end.nil?)
    result = { accuracy: value }
    result = Sequel.|({ accuracy: nil }) if value.begin.nil?
    result
  end

end

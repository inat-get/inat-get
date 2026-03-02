# frozen_string_literal: true

require_relative 'set'
require_relative '../../types/iconic'

class INatGet::Data::Helper::Field::Iconic < INatGet::Data::Helper::Field::Set

  def initialize helper, key
    super helper, key, lambda { |v| v.is_a?(String) || v.is_a?(Enumerable) || v.is_a?(INatGet::Data::Enum::Iconic) }
  end

  def to_sequel value
    { taxon_id: value_to_sequel(value) }
  end

  def value_to_sequel value
    case value
    when Enumerable
      value.map { |v| value_to_sequel(v) }.to_set
    when INatGet::Data::Enum::Iconic
      value.taxon_id
    when String
      INatGet::Data::Enum::Iconic::parse(value).taxon_id
    else
      value
    end
  end

end

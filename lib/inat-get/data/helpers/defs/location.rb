# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Helper::Field::Location < INatGet::Data::Helper::Field

  def valid? value
    value.nil? || (value.is_a?(Array) && value[0].is_a?(Float) && value[1].is_a?(Float))
  end

  def prepare value
    {
      latitude: (value[0] .. value[0]),
      longitude: (value[1] .. value[1])
    }
  end

end

# frozen_string_literal: true

require_relative 'scalar'

class INatGet::Data::Helper::Field::ScalarCoord < INatGet::Data::Helper::Field::Scalar

  def initialize helper, key
    super helper, key, Float
  end

  def to_api value
    case @key
    when :latitude
      { lat: value.begin }
    when :longitude
      { lng: value.begin }
    end
  end

end

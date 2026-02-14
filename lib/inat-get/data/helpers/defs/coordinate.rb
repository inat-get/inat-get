# frozen_string_literal: true

require_relative 'range'

class INatGet::Data::Helper::Field::Coordinate < INatGet::Data::Helper::Field::Range

  def initialize helper, key
    super helper, key, Float
  end

  def to_api value
    if value.begin == value.end
      case @key
      when :latitude
        { lat: value.begin }
      when :longitude
        { lng: value.begin }
      end
    else
      case @key
      when :latitude
        { swlat: value.begin, nelat: value.end }
      when :longitude
        { swlng: value.begin, nelng: value.end }
      end
    end
  end

end

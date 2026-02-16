# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Parser::Part::Location < INatGet::Data::Parser::Part

  def parse source
    geojson = source[:geojson]
    if geojson
      coordinates = geojson[:coordinates]
      if coordinates
        {
          latitude: coordinates[1],
          longitude: coordinates[0],
          accuracy: source[:positional_accuracy]
        }
      else
        {}
      end
    else
      {}
    end
  end

end

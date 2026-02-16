# frozen_string_literal: true

class INatGet::Data::Parser::Part::Location < INatGet::Data::Parser::Part

  def apply target, source
    geojson = source[:geojson]
    coordinates = geojson&.[](:coordinates)
    accuracy = source[:positional_accuracy]
    fields = {
      latitude: coordinates&.[](1),
      longitude: coordinates&.[](0),
      accuracy: accuracy
    }
    target.set(**fields)
  end

end

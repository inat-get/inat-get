# frozen_string_literal: true

require_relative 'location'

class INatGet::Data::Helper::Field::ScalarLocation < INatGet::Data::Helper::Field::Location

  def prepare value
    {
      latitude: value[0],
      longitude: value[1]
    }
  end

end

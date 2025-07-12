# frozen_string_literal: true

require_relative 'models'

class INatGet::Data::Helper::Field::Place < INatGet::Data::Helper::Field::Models

  def initialize helper, key
    super helper, key, INatGet::Data::Model::Place
  end

  def to_sequel value
    { places: value }
  end

end

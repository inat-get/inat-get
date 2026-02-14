# frozen_string_literal: true

require_relative 'models'

class INatGet::Data::Helper::Field::Project < INatGet::Data::Helper::Field::Models

  def initialize helper, key
    super helper, key, INatGet::Data::Model::Project
  end

  def to_sequel value
    value = [ value ] unless value.is_a?(Enumerable)
    Sequel.|( *value.map(&:to_sequel) )
  end

end

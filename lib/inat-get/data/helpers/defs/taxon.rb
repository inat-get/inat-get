# frozen_string_literal: true

require_relative 'models'

class INatGet::Data::Helper::Field::Taxon < INatGet::Data::Helper::Field::Models

  def initialize helper, key
    super helper, key, INatGet::Data::Model::Taxon
  end

  def to_sequel value
    value = [ value ] unless value.is_a?(Enumerable)
    Sequel.|( *value.map { |v| { taxon: v.descendants_dataset } } )
  end

end

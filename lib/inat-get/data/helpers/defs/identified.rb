# frozen_string_literal: true

require_relative 'scalar'

class INatGet::Data::Helper::Field::Identified < INatGet::Data::Helper::Field::Scalar

  def initialize helper, key
    super helper, key, Boolean
  end

  def to_sequel value
    if value
      Sequel.~(taxon_id: nil)
    else
      { taxon_id: nil }
    end
  end

end

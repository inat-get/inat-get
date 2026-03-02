# frozen_string_literal: true

require_relative "scalar"

class INatGet::Data::Helper::Field::Verifiable < INatGet::Data::Helper::Field::Scalar

  def initialize(helper, key)
    super helper, key, Boolean
  end

  def to_sequel(value)
    if value
      Sequel.~(quality_grade: 'casual')
    else
      { quality_grade: 'casual' }
    end
  end

end

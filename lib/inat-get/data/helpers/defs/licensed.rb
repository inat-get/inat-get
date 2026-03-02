# frozen_string_literal: true

require_relative "scalar"

class INatGet::Data::Helper::Field::Licensed < INatGet::Data::Helper::Field::Scalar

  def initialize(helper, key)
    super helper, key, Boolean
  end

  def to_sequel(value)
    if value
      Sequel.~(license: nil)
    else
      { license: nil }
    end
  end

end

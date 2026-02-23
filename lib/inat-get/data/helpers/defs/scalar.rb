# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Helper::Field::Scalar < INatGet::Data::Helper::Field

  def initialize helper, key, check
    super helper, key
    @check = check
  end

  def valid? value
    value.nil? || check === value
  end

end

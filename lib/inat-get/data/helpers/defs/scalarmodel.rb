# frozen_string_literal: true

require_relative 'scalar'

class INatGet::Data::Helper::Field::ScalarModel < INatGet::Data::Helper::Field::Scalar

  def initialize helper, key, check
    super helper, key, check
  end

  def to_api value
    { "#{ key }_id".to_sym => value.id }
  end

end

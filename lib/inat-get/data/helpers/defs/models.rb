# frozen_string_literal: true

require_relative 'set'

class INatGet::Data::Helper::Field::Models < INatGet::Data::Helper::Field::Set

  def to_api value
    { "#{ @key }_id".to_sym => value.map(&:id).to_set }
  end

end

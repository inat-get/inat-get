# frozen_string_literal: true

require_relative 'has'

class INatGet::Data::Helper::Field::Licenses < INatGet::Data::Helper::Field::Has

  def initialize helper, key, association
    super helper, key, association
    @check = lambda { |v| String === v || Enumerable === v }
  end

  def to_sequel value
    @extra = { license: value }
    super value
  end

end

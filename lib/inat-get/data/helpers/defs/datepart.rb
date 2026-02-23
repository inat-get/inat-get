# frozen_string_literal: true

require_relative 'set'

class INatGet::Data::Helper::Field::DatePart < INatGet::Data::Helper::Field::Set

  def initialize helper, key, drop = false
    super helper, key, Integer
    @drop = drop
  end

  def to_api value
    return {} if @drop
    { @key.to_s.gsub('observed_', '').to_sym => value }
  end

end

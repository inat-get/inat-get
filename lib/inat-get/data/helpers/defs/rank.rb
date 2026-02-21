# frozen_string_literal: true

require_relative 'set'
require_relative '../../types/rank'

class INatGet::Data::Helper::Field::Rank < INatGet::Data::Helper::Field::Set

  def initialize helper, key
    super helper, key, INatGet::Data::Enum::Rank
  end

  def valid? value
    if value.is_a?(Range)
      (value.begin.nil? || value.begin.is_a?(INatGet::Data::Enum::Rank)) && (value.end.nil? || value.end.is_a?(INatGet::Data::Enum::Rank))
    else
      super value
    end
  end

  def prepare value
    if value.is_a?(Range)
      b = value.begin || INatGet::Data::Enum::Rank.first
      e = value.end   || INatGet::Data::Enum::Rank.last
      (b..e).to_a.to_set
    else
      super value
    end
  end

  def to_api value
    value.map(&:to_s)
  end

  def to_sequel value
    { @key => value.map(&:to_s) }
  end

end

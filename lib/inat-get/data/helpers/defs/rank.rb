# frozen_string_literal: true

require_relative 'set'
require_relative '../../types/rank'

class INatGet::Data::Helper::Field::Rank < INatGet::Data::Helper::Field::Set

  def initialize helper, key
    super helper, key, INatGet::Data::Enum::Rank
  end

  def valid? value
    if value.is_a?(::Range)
      (value.begin.nil? || value.begin.is_a?(INatGet::Data::Enum::Rank)) && (value.end.nil? || value.end.is_a?(INatGet::Data::Enum::Rank))
    else
      super value
    end
  end

  def prepare value
    if value.is_a?(::Range)
      # b = value.begin || INatGet::Data::Enum::Rank.first
      # e = value.end   || INatGet::Data::Enum::Rank.last
      # (b..e).to_a.to_set
      # { :rank_level => (value.begin&.level .. value.end&.level) }
      value
    else
      super value
    end
  end

  def to_api value
    # value.map(&:to_s)
    if value.is_a?(::Range)
      result = {}
      result[:lrank] = value.begin.to_s if value.begin
      result[:hrank] = value.end.to_s   if value.end
      result
    else
      value
    end
  end

  def to_sequel value
    cond = case value
    when ::Range
      { rank_level: (value.begin&.level .. value.end&.level) }
    when Enumerable
      { rank: value.map(&:to_s) }
    when INatGet::Data::Enum::Rank
      { rank: value.to_s }
    else
      { rank: value }
    end
    if self.helper.endpoint == :observations
      require_relative '../../models/taxon'
      { taxon_id: INatGet::Data::Model::Taxon.where(cond).select(:id) }
    else
      cond
    end
  end

end

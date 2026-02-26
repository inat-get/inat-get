# frozen_string_literal: true

module INatGet::Data::Enum; end

class INatGet::Data::Enum::Iconic < IS::Enum

  define :Aves,           id: 3
  define :Amphibia,       id: 20978
  define :Reptilia,       id: 26036
  define :Mammalia,       id: 40151
  define :Actinopterygii, id: 47178
  define :Mollusca,       id: 47115
  define :Insecta,        id: 47158
  define :Arachnida,      id: 47119
  define :Animalia,       id: 1
  define :Plantae,        id: 47126
  define :Fungi,          id: 47170
  define :Chromista,      id: 48222
  define :Protozoa,       id: 47686
  define :unknown

  # @return [Integer, nil]
  def taxon_id
    @attrs[:id]
  end

  class << self

    def by_id id
      @@by_ids ||= fill_hash
      @@by_ids[id] || self.unknown
    end

    private def fill_hash
      result = {}
      self.each do |item|
        result[item.taxon_id] = item
      end
      result
    end

  end

end

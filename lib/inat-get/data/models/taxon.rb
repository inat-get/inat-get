# frozen_string_literal: true

require 'sequel'

require_relative '../../info'

class INatGet::Data::Model::Taxon < INatGet::Data::Model

  set_dataset :taxa

  one_to_many :observations
  one_to_many :identifications

  many_to_one :iconic_taxon, class: INatGet::Data::Model::Taxon
  many_to_one :parent, class: INatGet::Data::Model::Taxon

  many_to_many :ancestors, class: INatGet::Data::Model::Taxon, join_table: :taxa_ancestors, left_key: :taxon_id, right_key: :ancestor_id
  many_to_many :descendants, class: INatGet::Data::Model::Taxon, join_table: :taxa_ancestors, left_key: :ancestor_id, right_key: :taxon_id

  class << self

    def manager = INatGet::Data::Manager::Taxa::instance

    # @group Taxonomy

    def compact_set *values
      result = ::Set[]
      values.each do |value|
        found = result.find { |v| v === value }
        next if found
        found = result.find { |v| value === v }
        result.delete found if found
        result << value
      end
      result
    end

    # @endgroup

  end

  # @group Taxonomy

  # @overload === nil
  #   @param [nil] nil
  #   @return [false]
  # @overload === taxon
  #   @param [Taxon] taxon
  #   @return [Boolean]
  # @overload === item
  #   @param [Observation, Identification] item
  #   @return [Boolean]
  # @overload === other
  #   @param [Object] other
  #   @return [nil]
  # @return [Boolean, nil]
  def === other
    case other
    when nil
      false
    when INatGet::Data::Model::Taxon
      return true if self.id == other.id
      Taxon.where(id: other.id)
           .where(id: Taxon.select(:taxon_id)
                           .from(:taxa_ancestors)
                           .where(ancestor_id: self.id))
           .exists?
    when INatGet::Data::Model::Observation, INatGet::Data::Model::Identification
      self === value.taxon
    else
      nil
    end
  end

  # @endgroup

end

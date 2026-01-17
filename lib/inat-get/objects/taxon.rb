# frozen_string_literal: true

require 'sequel'

require_relative '../info'

module INatGet::Models; end

class INatGet::Models::Taxon < Sequel::Model(:taxa)

  one_to_many :observations
  one_to_many :identifications

  many_to_one :iconic_taxon, class: self
  many_to_one :parent, class: self

  many_to_many :ancestors, class: self, join_table: :taxa_ancestors, left_key: :taxon_id, right_key: :ancestor_id
  many_to_many :descendants, class: self, join_table: :taxa_ancestors, left_key: :ancestor_id, right_key: :taxon_id

end

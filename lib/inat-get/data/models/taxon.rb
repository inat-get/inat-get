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

  end

end

# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Taxon < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :name, :is_active, :rank, :rank_level, :common_name => :preferred_common_name, :english_name => :english_common_name
  # part Part::Model, :parent,       model: INatGet::Data::Model::Taxon
  # part Part::Model, :iconic_taxon, model: INatGet::Data::Model::Taxon
  part Part::Cached

  # part Part::Ancestry, :ancestors

  def model() = INatGet::Data::Model::Taxon

  def fake id
    self.model.create id: id, name: "Fake #{ id }", is_active: false, cached: Time::now
  end

end

# frozen_string_literal: true

require 'singleton'

require_relative 'base'
require_relative 'defs/pk'
require_relative 'defs/copy'
require_relative 'defs/cached'
require_relative 'defs/assmodel'
require_relative 'defs/ancestry'

class INatGet::Data::Parser::Taxon < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :name, :is_active, :rank, :rank_level, :common_name => :preferred_common_name, :english_name => :english_common_name
  part Part::Cached

  part Part::Ancestry, :ancestors
  part Part::AssModel, :parent, model: INatGet::Data::Model::Taxon
  part Part::AssModel, :iconic_taxon, model: INatGet::Data::Model::Taxon

  def inner_key() = :taxa

  def fake id
    self.model.create id: id, name: "Fake #{ id }", is_active: false, cached: Time::now
  end

end

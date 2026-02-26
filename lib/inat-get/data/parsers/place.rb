# frozen_string_literal: true

require 'singleton'

require_relative 'base'
require_relative 'defs/pk'
require_relative 'defs/copy'
require_relative 'defs/json'
require_relative 'defs/strlocation'
require_relative 'defs/cached'
require_relative 'defs/ancestry'

class INatGet::Data::Parser::Place < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :admin_level, :place_type, :name, :display_name, :slug, :uuid
  part Part::JSON, :bounding_box => :bounding_box_geojson, :geometry => :geometry_geojson
  part Part::StrLocation
  part Part::Cached

  part Part::Ancestry, :ancestors, source_ids: :ancestor_place_ids

  # def manager = INatGet::Data::Manager::Places::instance
  def model() = INatGet::Data::Model::Place

  def fake id
    self.model.create id: id, name: "Fake \##{ id }", display_name: "Fake \##{ id }", slug: "fake-#{ id }", cached: DateTime::now
  end

end

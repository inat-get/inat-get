# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Place < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :admin_level, :place_type, :name, :display_name, :slug, :uuid
  part Part::JSON, :bounding_box => :bounding_box_geojson, :geometry => :geometry_geojson
  part Part::StrLocation
  part Part::Cached

  part Part::Links :ancestors, model: INatGet::Data::Model::Place, source_ids: :ancestor_place_ids

  class << self

    def manager = INatGet::Data::Manager::Places::instance

  end

end

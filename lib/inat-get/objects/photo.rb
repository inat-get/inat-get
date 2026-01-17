# frozen_string_literal: true

require "sequel"

require_relative "../info"

module INatGet::Models; end

class INatGet::Models::Photo < Sequel::Model(:photos)

  many_to_many :observations, class: :'INatGet::Models::Observation', join_table: :observation_photos, left_key: :photo_id, right_key: :observation_id

end

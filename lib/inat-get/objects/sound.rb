# frozen_string_literal: true

require "sequel"

require_relative "../info"

module INatGet::Models; end

class INatGet::Models::Sound < Sequel::Model(:sounds)

  many_to_many :observations, class: :'INatGet::Models::Observation', join_table: :observation_sounds, left_key: :sound_id, right_key: :observation_id

end

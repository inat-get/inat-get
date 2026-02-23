# frozen_string_literal: true

require "sequel"

require_relative "../../info"
require_relative '../parsers/sound'

class INatGet::Data::Model::Sound < INatGet::Data::Model

  set_dataset :sounds

  many_to_many :observations, class: :'INatGet::Data::Model::Observation', join_table: :observation_sounds, left_key: :sound_id, right_key: :observation_id

  class << self

    def parser() = INatGet::Data::Parser::Sound::instance

  end

end

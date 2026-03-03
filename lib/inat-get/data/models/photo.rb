# frozen_string_literal: true

require "sequel"

require_relative "../../info"

module INatGet::Data; end

class INatGet::Data::Model::Photo < INatGet::Data::Model

  set_dataset :photos

  many_to_many :observations, class: :'INatGet::Data::Model::Observation', join_table: :observation_photos, left_key: :photo_id, right_key: :observation_id

end

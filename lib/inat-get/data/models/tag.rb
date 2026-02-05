# frozen_string_literal: true

require "sequel"

require_relative "../../info"

module INatGet::Data; end
module INatGet::Data::Model; end

class INatGet::Data::Model::Tag < Sequel::Model

  set_dataset :observation_tags

  many_to_one :observation, class: :'INatGet::Data::Model::Observation'

end

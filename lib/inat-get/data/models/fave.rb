# frozen_string_literal: true

require "sequel"

require_relative "../../info"

module INatGet::Data; end
module INatGet::Data::Model; end

class INatGet::Data::Model::Fave < Sequel::Model

  set_dataset :observation_faves

  many_to_one :observation

end

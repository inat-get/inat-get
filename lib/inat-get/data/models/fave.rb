# frozen_string_literal: true

require 'sequel'

require_relative '../../info'
require_relative 'base'

module INatGet::Data; end

class INatGet::Data::Model::Fave < INatGet::Data::Model

  set_dataset :observation_faves

  many_to_one :observation

  include INatGet::Data::Model::Sub

  def owner = self.observation

end

# frozen_string_literal: true

require "sequel"

require_relative "../info"

module INatGet::Models; end

class INatGet::Models::Fave < Sequel::Model(:observation_faves)

  many_to_one :observation

end

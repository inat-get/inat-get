# frozen_string_literal: true

require "sequel"

require_relative "../info"

module INatGet::Models; end

class INatGet::Models::Tag < Sequel::Model(:tags)

  many_to_one :observation, class: :'INatGet::Models::Observation'

end

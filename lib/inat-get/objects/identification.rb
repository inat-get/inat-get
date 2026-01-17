# frozen_string_literal: true

require "sequel"

require_relative "../info"

module INatGet::Models; end

class INatGet::Models::Identification < Sequel::Model(:identifications)

  many_to_one :observation
  many_to_one :taxon
  many_to_one :user

end

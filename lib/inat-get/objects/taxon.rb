# frozen_string_literal: true

require 'sequel'

require_relative '../info'

module INatGet::Models; end

class INatGet::Models::Taxon < Sequel::Model(:taxa)

  one_to_many :observations

end

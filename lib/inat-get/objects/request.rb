# frozen_string_literal: true

require 'sequel'

require_relative '../info'

module INatGet::Models; end

class INatGet::Models::Request < Sequel::Model(:requests)

end

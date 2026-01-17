# frozen_string_literal: true

require 'sequel'

require_relative "../info"

module INatGet::Models; end

class INatGet::Models::ProjectAdmin < Sequel::Model(:project_admins)

  many_to_one :project
  many_to_one :user

end

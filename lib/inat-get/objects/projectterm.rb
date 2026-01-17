# frozen_string_literal: true

require "sequel"

require_relative "../info"

module INatGet::Models; end

class INatGet::Models::ProjectTerm < Sequel::Model(:project_terms)

  many_to_one :projects

end

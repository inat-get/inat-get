# frozen_string_literal: true

require "sequel"

require_relative "../../info"

class INatGet::Data::Model::ProjectTerm < INatGet::Data::Model

  set_dataset :project_terms

  many_to_one :project

  include INatGet::Data::Model::Sub

  def owner = self.project

end

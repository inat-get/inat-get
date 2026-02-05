# frozen_string_literal: true

require "sequel"

require_relative "../../info"

module INatGet::Data; end
module INatGet::Data::Model; end

class INatGet::Data::Model::ProjectTerm < Sequel::Model

  set_dataset :project_terms

  many_to_one :project

  include INatGet::Data::Model::Sub

  def owner = self.project

end

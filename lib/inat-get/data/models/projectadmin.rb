# frozen_string_literal: true

require 'sequel'

require_relative "../../info"

class INatGet::Data::Model::ProjectAdmin < INatGet::Data::Model

  set_dataset :project_admins

  many_to_one :project
  many_to_one :user

  include INatGet::Data::Model::Sub

  def owner = self.project

end

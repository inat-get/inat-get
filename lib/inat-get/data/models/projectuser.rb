# frozen_string_literal: true

# @api private
class INatGet::Data::Model::ProjectUser < INatGet::Data::Model

  set_dataset :project_users

  many_to_one :project
  many_to_one :user

  include Sub

  def owner() = self.project

end

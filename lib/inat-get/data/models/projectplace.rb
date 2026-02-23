# frozen_string_literal: true

# @api private
class INatGet::Data::Model::ProjectPlace < INatGet::Data::Model

  set_dataset :project_places

  many_to_one :project
  many_to_one :place

  include Sub

  def owner() = self.project

end

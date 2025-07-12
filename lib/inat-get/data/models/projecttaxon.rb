# frozen_string_literal: true

# @api private
class INatGet::Data::Model::ProjectTaxon < INatGet::Data::Model

  set_dataset :project_taxa

  many_to_one :project
  many_to_one :taxon

  include Sub

  def owner() = self.project

end

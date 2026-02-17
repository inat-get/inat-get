# frozen_string_literal: true

class INatGet::Data::Parser::ProjectAdmin < INatGet::Data::Parser

  include Singleton

  part Part::PK, :project_id => :owner_id
  part Part::Copy, :role
  part Part::Model, :user, model: INatGet::Data::Model::User

  def model() = INatGet::Data::Model::ProjectAdmin

end

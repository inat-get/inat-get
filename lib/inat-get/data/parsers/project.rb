# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Project < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :slug, :title, :description
  part Part::PrjType
  part Part::Time, :created => :created_at, :updated => :updated_at
  part Part::Model, :user, model: INatGet::Data::Model::User
  part Part::PrjDefault
  part Part::Cached

  part Part::Children, :admins, model: INatGet::Data::Model::ProjectAdmin
  part Part::Links, :members, model: INatGet::Data::Model::User, source_ids: :user_ids
  part Part::PrjRules
  part Part::PrjSearch
  part Part::Subprojects

  def manager() = INatGet::Data::Manager::Projects::instance

  def fake id
    self.model.create id: id, slug: "fake-#{ id }", title: "Fake \##{ id }", description: "Fake project \##{ id }", project_type: '',
                      created: Time::now, updated: Time::now, cached: Time::now, 
                      is_umbrella: false, is_collection: false, members_only: false, user: INatGet::Data::Manager::Users.get(0)
  end

end

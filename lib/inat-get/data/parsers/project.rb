# frozen_string_literal: true

require 'singleton'

require_relative 'base'
require_relative 'defs/pk'
require_relative 'defs/copy'
require_relative 'defs/prjtype'
require_relative 'defs/time'
require_relative 'defs/model'
require_relative 'defs/prjdefault'
require_relative 'defs/cached'
require_relative 'defs/children'
require_relative 'defs/links'
require_relative 'defs/prjrules'
require_relative 'defs/prjsearch'
require_relative 'defs/subprojects'
require_relative 'defs/prjmembers'
require_relative '../models/project'

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
  # part Part::Links, :members, model: INatGet::Data::Model::User, source_ids: :user_ids
  # part Part::PrjMembers
  part Part::PrjRules
  part Part::PrjSearch
  part Part::Subprojects

  def model() = INatGet::Data::Model::Project

  def fake id
    self.model.create id: id, slug: "fake-#{ id }", title: "Fake \##{ id }", description: "Fake project \##{ id }", project_type: '',
                      created: Time::now, updated: Time::now, cached: Time::now, 
                      is_umbrella: false, is_collection: false, members_only: false, user: INatGet::Data::Manager::Users.get(0)
  end

end

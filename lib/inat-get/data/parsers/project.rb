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

  class << self

    def manager() = INatGet::Data::Manager::Projects::instance

  end

end

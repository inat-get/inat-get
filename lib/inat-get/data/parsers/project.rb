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
  part Part::Cached

  # TODO

  class << self

    def manager() = INatGet::Data::Manager::Projects::instance

  end

end

# frozen_string_literal: true

require_relative 'base'
require_relative '../models/project'
require_relative '../helpers/projects'
require_relative '../parsers/project'
require_relative '../updaters/projects'

class INatGet::Data::Manager::Projects < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:projects]
  def endpoint = :projects

  # @return [INatGet::Data::Model::Project]
  def model = INatGet::Data::Model::Project

  # @return [:slug]
  def sid = :slug

  # @return [INatGet::Data::Helper::Projects]
  def helper = INatGet::Data::Helper::Projects::instance

  # @return [INatGet::Data::Parser::Project]
  def parser = INatGet::Data::Parser::Project::instance

  # @return [INatGet::Data::Updater::Projects]
  def updater = INatGet::Data::Updater::Projects::instance

  # @endgroup

end

module INatGet::Data::DSL

  # @group Data Querying

  # @return [INatGet::Data::Model::Project, nil]
  def get_project(id) = INatGet::Data::Manager::Projects::instance[id]

  # @return [Enumerable<INatGet::Data::Model::Project>]
  def select_projects *args, **query
    result = INatGet::Data::Manager::Projects::instance.get(*args, **query)
    case result
    when Sequel::Model
      [ result ]
    when nil
      []
    else
      result
    end
  end

end

# frozen_string_literal: true

require_relative 'base'
require_relative '../models/user'
require_relative '../helpers/users'
require_relative '../parsers/user'
require_relative '../updaters/users'

class INatGet::Data::Manager::Users < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:users]
  def endpoint = :users

  # @return [INatGet::Data::Model::User]
  def model = INatGet::Data::Model::User

  # @return [:login]
  def sid = :login

  # @return [INatGet::Data::Helper::Users]
  def helper = INatGet::Data::Helper::Users::instance

  # @return [INatGet::Data::Parser::User]
  def parser = INatGet::Data::Parser::User::instance

  # @return [INatGet::Data::Updater::Users]
  def updater = INatGet::Data::Updater::Users::instance

  # @endgroup

end

module INatGet::Data::DSL

  # @group Data Querying

  # @return [INatGet::Data::Model::User, nil]
  def get_user(id) = INatGet::Data::Manager::Users::instance[id]

  # @return [Array<INatGet::Data::Model::User>]
  def select_users *ids
    result = INatGet::Data::Manager::Users::instance.get(*ids)
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

# frozen_string_literal: true

require_relative 'base'
# require_relative '../models/user'
# require_relative '../helpers/users'
# require_relative '../parsers/user'
# require_relative '../updaters/users'

class INatGet::Data::Manager::Users < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:users]
  def endpoint = :users

  # @return [:login]
  def sid = :login

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

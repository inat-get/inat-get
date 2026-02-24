# frozen_string_literal: true

require 'singleton'

require_relative 'base'
require_relative 'defs/ids'

class INatGet::Data::Helper::Users < INatGet::Data::Helper

  include Singleton

  field :id,    INatGet::Data::Helper::Field::Ids
  field :login, INatGet::Data::Helper::Field::Ids

  # @return [INatGet::Data::Manager::Users]
  def manager() = INatGet::Data::Manager::Users::instance

  # @return [Array<Hash>]
  def query_to_api **query
    endpoint = self.manager.endpoint
    values = (query[:id] || []).to_set + (query[:login] || []).to_set
    values.map { |v| { endpoint: "#{ endpoint }/#{ v }", query: {} } }
  end

end

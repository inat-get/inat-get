# frozen_string_literal: true

require 'singleton'

require_relative 'base'
require_relative 'defs/ids'

class INatGet::Data::Helper::Places < INatGet::Data::Helper

  include Singleton

  # @return [INatGet::Data::Manager::Places]
  def manager() = INatGet::Data::Manager::Places::instance

  field :id, INatGet::Data::Helper::Field::Ids
  field :slug, INatGet::Data::Helper::Field::Ids

  # @return [Array<Hash>]
  def query_to_api **query
    endpoint = self.manager.endpoint
    values = (query[:id] || []).to_set + (query[:slug] || []).to_set
    blocks = values.each_slice(200).to_a
    blocks.map { |v| { endpoint: "#{ endpoint }/#{ v.map(&:to_s).join(',') }", query: {} } }
  end

end

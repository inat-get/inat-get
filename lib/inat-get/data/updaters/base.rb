# frozen_string_literal: true

require 'is-duration'

require_relative '../../info'

# @api private
class INatGet::Data::Updater

  include IS::Duration

  def initialize
    @config = INatGet::App::Setup::config[:caching] || {}
  end

  # @overload update! condition
  #   @param [INatGet::Data::DSL::Condition] conditions
  # @overload update! *ids
  #   @param [Array<Integer, String>] ids
  # @return [void]
  def update! *args
    if args.size == 1 && args.first.is_a?(INatGet::Data::DSL::Condition)
      update_by_condition! arg.first
    else
      update_by_ids!(*args)
    end
  end

  # @return [INatGet::Data::Parser]
  def parser() = self.manager.parser

  # @return [INatGet::Data::Manager]
  def manager() = raise NotImplementedError, "Not implemented method 'manager' for abstract class", caller_locations

  # @return [INatGet::Data::Model]
  def model() = self.manager.model

  # @return [INatGet::Data::Helper]
  def helper() = self.manager.helper

  private

  def api
    @api ||= Thread::current[:api]
  end

  def update_by_condition! condition
    make_request condition.to_api
  end

  def update_by_ids! *ids
    interval = parse_duration(@config.dig(:refs, self.manager.endpoint) || @config.dig(:refs, :default))
    if interval
      point = Time::now - interval
      fresh = self.model.where(id: ids, cached: (point .. )).select_map(:id)
      ids -= fresh
    end
    endpoint = self.manager.endpoint + '/' + ids.map(&:to_s).join(',')
    request = { endpoint: endpoint, query: {} }
    make_request request
  end

  def make_request request
    prepared = { endpoint: request[:endpoint], query.transform_values { |v| v.is_a?(Enumerable) ? v.sort : v } }
    json = JSON.stringify prepared, sort_keys: true, space: ''
    hash = Digest::MD5::hexdigest json
    #
  end

end

# frozen_string_literal: true

require_relative 'base'
require_relative '../models/observation'
require_relative '../helpers/observations'
require_relative '../parsers/observation'
require_relative '../updaters/observations'

class INatGet::Data::Manager::Observations < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:observations]
  def endpoint = :observations

  # @return [class INatGet::Data::Model::Observation]
  def model = INatGet::Data::Model::Observation

  # @return [true]
  def uuid? = true

  # @return [INatGet::Data::Helper::Observations]
  def helper = INatGet::Data::Helper::Observations::instance

  # @return [INatGet::Data::Parser::Observation]
  def parser = INatGet::Data::Parser::Observation::instance

  # @return [INatGet::Data::Updater::Observations]
  def updater = INatGet::Data::Updater::Observations::instance

  # @endgroup

end

module INatGet::Data::DSL

  # @group Data Querying

  # @return [Enumerable<Model::Observation>]
  # @overload observations *ids
  #   @param [Array<Integer, String>] ids +String+ for UUIDs
  #   @return [Array<Model::Observation>]
  # @overload observations condition
  #   @param [Condition] condition
  #   @return [Dataset<Model::Observation>]
  # @overload observations **query
  #   @param [Hash] query
  #   @return [Dataset<Model::Observation>]
  def observations *args, **query
    result = INatGet::Data::Manager::Observations::instance.get(*args, **query)
    case result
    when Sequel::Model
      [ result ]
    when nil
      []
    else
      result
    end
  end

  # @overload observation id
  #   @param [Integer] id
  # @overload observation uuid
  #   @param [String] uuid
  # @return [Model::Observation, nil]
  def observation(id) = INatGet::Data::Manager::Observations::instance[id]

end

# frozen_string_literal: true

require_relative 'base'
require_relative '../models/identification'
require_relative '../helpers/identifications'
require_relative '../parsers/identification'
require_relative '../updaters/identifications'

class INatGet::Data::Manager::Identifications < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:identifications]
  def endpoint = :identifications

  # @return [class INatGet::Data::Model::Identification]
  def model = INatGet::Data::Model::Identification

  # @return [true]
  def uuid? = true

  # @return [INatGet::Data::Helper::Identifications]
  def helper = INatGet::Data::Helper::Identifications::instance

  # @return [INatGet::Data::Parser::Identification]
  def parser = INatGet::Data::Parser::Identification::instance

  # @return [INatGet::Data::Updater::Identifications]
  def updater = INatGet::Data::Updater::Identifications::instance

  # @endgroup

end

module INatGet::Data::DSL

  # @group Data Querying

  # @return [Enumerable<Model::Identification>]
  # @overload select_identifications *ids
  #   @param [Array<Integer, String>] ids (String for UUID)
  #   @return [Array<Model::Identification>]
  # @overload select_identifications condition
  #   @param [Condition] condition
  #   @return [Dataset<Model::Identification>]
  # @overload select_identifications **query
  #   @param [Hash] query
  #   @return [Dataset<Model::Identification>]
  def select_identifications(*args, **query)
    result = INatGet::Data::Manager::Identifications::instance.get(*args, **query)
    case result
    when Sequel::Model
      [ result ]
    when nil
      []
    else
      result
    end
  end

  # @overload get_identification id
  #   @param [Integer] id
  # @overload get_identification uuid
  #   @param [String] uuid
  # @return [Model::Identification, nil]
  def get_identification(id) = INatGet::Data::Manager::Identifications::instance[id]

  # @endgroup

end

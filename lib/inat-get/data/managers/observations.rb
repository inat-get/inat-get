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
  # @overload select_observations *ids
  #   @param [Array<Integer, String>] ids `String` for UUIDs
  #   @return [Array<Model::Observation>]
  # @overload select_observations condition
  #   @param [Condition] condition
  #   @return [Dataset<Model::Observation>]
  # @overload select_observations **query
  #   @param [Hash] query
  #   @option query [Integer, Enumerable<Integer>] id:
  #   @option query [String, Enumerable<String>] uuid:
  #   @option query [Boolean] captive:
  #   @option query [Boolean] endemic:
  #   @option query [Boolean] identified:
  #   @option query [Boolean] introduced:
  #   @option query [Boolean] native:
  #   @option query [Boolean] out_of_range:
  #   @option query [Boolean] popular:
  #   @option query [Boolean] photos:
  #   @option query [Boolean] sounds:
  #   @option query [Boolean] threatened:
  #   @option query [Boolean] verifiable:
  #   @option query [Boolean] licensed:
  #   @option query [Boolean] photo_licensed:
  #   @option query [Boolean] sound_licensed:
  #   @option query [Model::Place, Enumerable<Model::Place>] place:
  #   @option query [Model::Project, Enumerable<Model::Project>] project:
  #   @option query [Model::Taxon, Enumerable<Model::Taxon>] taxon:
  #   @option query [Model::User, Enumerable<Model::User>] user:
  #   @option query [Enum::Rank, Enumerable<Enum::Rank>, Range<Enum::Rank>] rank:
  #   @option query [Integer, Enumerable<Integer>] observed_year:
  #   @option query [Integer, Enumerable<Integer>] observed_month:
  #   @option query [Integer, Enumerable<Integer>] observed_week:
  #   @option query [Integer, Enumerable<Integer>] observed_day:
  #   @option query [Integer, Enumerable<Integer>] observed_hour:
  #   @option query [Integer, Enumerable<Integer>] created_year:
  #   @option query [Integer, Enumerable<Integer>] created_month:
  #   @option query [Integer, Enumerable<Integer>] created_week:
  #   @option query [Integer, Enumerable<Integer>] created_day:
  #   @option query [Integer, Enumerable<Integer>] created_hour:
  #   @option query [Date, Range<Time>] observed:
  #   @option query [Date, Range<Time>] created:
  #   @option query [Integer, nil] accuracy:
  #   @option query [String, Enumerable<String>] csi:
  #   @option query [String, Enumerable<String>] geoprivacy:
  #   @option query [String, Enumerable<String>] taxon_geoprivacy:
  #   @option query [String, Enumerable<String>] obscuration:
  #   @option query [String, Enumerable<String>] iconic_taxa:
  #   @option query [Float, Range<Float>] latitude:
  #   @option query [Float, Range<Float>] longitude:
  #   @option query [Float] radius:
  #   @option query [[FLoat, Float]] location:
  #   @option query [String, Enumerable<String>] quality_grade:
  #   @return [Dataset<Model::Observation>]
  def select_observations *args, **query
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

  # @overload get_observation id
  #   @param [Integer] id
  # @overload get_observation uuid
  #   @param [String] uuid
  # @return [Model::Observation, nil]
  def get_observation(id) = INatGet::Data::Manager::Observations::instance[id]

end

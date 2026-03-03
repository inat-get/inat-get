# frozen_string_literal: true

require_relative 'base'
# require_relative '../models/place'
# require_relative '../helpers/places'
# require_relative '../updaters/places'
# require_relative '../parsers/place'

class INatGet::Data::Manager::Places < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:places]
  def endpoint = :places

  # @return [:slug]
  def sid = :slug

  # @return [true]
  def uuid? = true

  # @endgroup

end

module INatGet::Data::DSL

  # @group Data Querying

  # @overload get_place id
  #   @param [Integer] id
  # @overload get_place uuid
  #   @param [String] uuid
  # @overload get_place slug
  #   @param [String] slug
  # @return [Model::Place, nil]
  def get_place(id) = INatGet::Data::Manager::Places::instance[id]

  # @return [Array<Model::Place>]
  # @param [Array<Integer, String>] ids
  def select_places *ids
    result = INatGet::Data::Manager::Places::instance.get(*ids)
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

# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Manager::Places < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:places]
  def endpoint = :places

  # @return [class INatGet::Data::Model::Place]
  def model = INatGet::Data::Model::Place

  # @return [:slug]
  def sid = :slug

  # @return [true]
  def uuid? = true

  # @return [INatGet::Data::Helper::Places]
  def helper = INatGet::Data::Helper::Places::instance

  # @return [INatGet::Data::Parser::Place]
  def parser = INatGet::Data::Parser::Place::instance

  # @return [INatGet::Data::Updater::Places]
  def updater = INatGet::Data::Updater::Places::instance

  # @endgroup

end

module INatGet::Data::DSL

  # @group Data Querying

  # @return [INatGet::Data::Model::Place, nil]
  def place(id) = INatGet::Data::Manager::Places::instance[id]

  # @return [Array<INatGet::Data::Model::Place>]
  def places *ids
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

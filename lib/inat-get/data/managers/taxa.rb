# frozen_string_literal: true

require_relative 'base'
require_relative '../models/taxon'
require_relative '../helpers/taxa'
require_relative '../parsers/taxon'
require_relative '../updaters/taxa'

class INatGet::Data::Manager::Taxa < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:taxa]
  def endpoint = :taxa

  # @return [INatGet::Data::Model::Taxon]
  def model = INatGet::Data::Model::Taxon

  # @return [INatGet::Data::Helper::Taxa]
  def helper = INatGet::Data::Helper::Taxa::instance

  # @return [INatGet::Data::Parser::Taxon]
  def parser = INatGet::Data::Parser::Taxon::instance

  # @return [INatGet::Data::Updater::Taxa]
  def updater = INatGet::Data::Updater::Taxa::instance

  # @endgroup

end

module INatGet::Data::DSL

  # @group Data Querying

  # @return [INatGet::Data::Model::Taxon, nil]
  def taxon(id) = INatGet::Data::Manager::Taxa::instance[id]

  # @return [Enumerable<INatGet::Data::Model::Taxon>]
  def taxa *args, **query
    result = INatGet::Data::Manager::Taxa::instance.get(*args, **query)
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


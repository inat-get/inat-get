# frozen_string_literal: true

require_relative 'base'
# require_relative '../models/taxon'
# require_relative '../helpers/taxa'
# require_relative '../parsers/taxon'
# require_relative '../updaters/taxa'

class INatGet::Data::Manager::Taxa < INatGet::Data::Manager

  include Singleton

  # @group Specificators

  # @return [:taxa]
  def endpoint = :taxa

  # @endgroup

end

module INatGet::Data::DSL

  # @group Data Querying

  # @return [INatGet::Data::Model::Taxon, nil]
  def get_taxon(id) = INatGet::Data::Manager::Taxa::instance[id]

  # @return [Enumerable<INatGet::Data::Model::Taxon>]
  def select_taxa *args, **query
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


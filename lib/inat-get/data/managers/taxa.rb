# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Manager::Taxa < INatGet::Data::Manager::Base

  include Singleton

  # @return [:taxa]
  def entrypoint = :taxa

  # @return [INatGet::Data::Model::Taxon]
  def model = INatGet::Data::Model::Taxon

end

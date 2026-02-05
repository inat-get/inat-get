# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Manager::Identifications < INatGet::Data::Manager::Base

  include Singleton

  # @return [:identifications]
  def entrypoint = :identifications

  # @return [class INatGet::Data::Model::Identification]
  def model = INatGet::Data::Model::Identification

end

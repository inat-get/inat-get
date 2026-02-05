# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Manager::Observations < INatGet::Data::Manager::Base

  include Singleton

  # @return [:observations]
  def entrypoint = :observations

  # @return [class INatGet::Data::Model::Observation]
  def model = INatGet::Data::Model::Observation

end

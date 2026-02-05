# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Manager::Places < INatGet::Data::Manager::Base

  include Singleton

  # @return [:places]
  def entrypoint = :places

  # @return [class INatGet::Data::Model::Place]
  def model = INatGet::Data::Model::Place

end


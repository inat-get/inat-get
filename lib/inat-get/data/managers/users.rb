# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Manager::Users < INatGet::Data::Manager::Base

  include Singleton

  # @return [:users]
  def entrypoint = :users

  # @return [INatGet::Data::Model::User]
  def model = INatGet::Data::Model::User

end

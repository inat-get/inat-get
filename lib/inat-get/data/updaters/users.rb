# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Users < INatGet::Data::Updater

  include Singleton

  # @return [INatGet::Data::Manager::Users]
  def manager() = INatGet::Data::Manager::Users::instance

  # @return [Integer]
  def slice_size() = 1

end

class INatGet::Data::Updater::ProjectUsers < INatGet::Data::Updater::Users

  include Singleton

  def slice_size() = 200

end

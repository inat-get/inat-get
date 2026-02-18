# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Users < INatGet::Data::Updater

  include Singleton

  # @return [INatGet::Data::Manager::Users]
  def manager() = INatGet::Data::Manager::Users::instance

end

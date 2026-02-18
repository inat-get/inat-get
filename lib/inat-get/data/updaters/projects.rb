# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Projects < INatGet::Data::Updater

  include Singleton

  # @return [INatGet::Data::Manager::Projects]
  def manager() = INatGet::Data::Manager::Projects::instance
  
end

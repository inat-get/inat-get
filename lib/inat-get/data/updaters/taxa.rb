# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Taxa < INatGet::Data::Updater

  include Singleton

  # @return [INatGet::Data::Manager::Taxa]
  def manager() = INatGet::Data::Manager::Taxa::instance

end


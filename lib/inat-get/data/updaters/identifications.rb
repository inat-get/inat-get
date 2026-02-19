# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Identifications < INatGet::Data::Updater

  include Singleton

  # @return [INatGet::Data::Manager::Identifications]
  def manager() = INatGet::Data::Manager::Identifications::instance

  private

  # @return [true]
  def allow_id_above?() = true

end

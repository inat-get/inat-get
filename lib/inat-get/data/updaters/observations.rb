# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Observations < INatGet::Data::Updater

  include Singleton

  # @return [INatGet::Data::Manager::Observations]
  def manager() = INatGet::Data::Manager::Observations::instance

  private

  # @return [true]
  def allow_locale?() = true

  # @return [true]
  def allow_id_above?() = true

  # @return [true]
  def allow_updated_since?() = true

end

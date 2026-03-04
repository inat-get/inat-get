# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Taxa < INatGet::Data::Updater

  include Singleton

  # @return [:taxa]
  def endpoint() = :taxa

  private

  # @return [true]
  def allow_locale?() = true

  # @return [true]
  def allow_id_above?() = true

end

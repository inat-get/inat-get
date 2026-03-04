# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Projects < INatGet::Data::Updater

  include Singleton

  # @return [:projects]
  def endpoint() = :projects
  
end

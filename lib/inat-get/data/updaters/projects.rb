# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Projects < INatGet::Data::Updater

  include Singleton

  def parser() = INatGet::Data::Parser::Project::instance
  
end

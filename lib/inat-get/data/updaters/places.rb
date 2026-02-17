# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Places < INatGet::Data::Updater

  include Singleton

  def parser() = INatGet::Data::Parser::Place::instance

end

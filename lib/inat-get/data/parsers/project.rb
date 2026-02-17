# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Project < INatGet::Data::Parser

  include Singleton

  # TODO

  class << self

    def manager = INatGet::Data::Manager::Projects::instance

  end

end

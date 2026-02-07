# frozen_string_literal: true

require_relative '../../info'

module INatGet::Data; end

module INatGet::Data::Model

  # @api private
  module Meta

    def manager = raise NotImplementedError, "Not implemented method 'manager' in abstract class", caller_locations

    def helper = self.manager.helper

    def updater = self.manager.updater

    def parser = self.manager.parser

  end

  class << self

    def included cls
      cls.extend INatGet::Data::Model::Meta
    end

  end

end

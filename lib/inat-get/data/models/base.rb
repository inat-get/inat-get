# frozen_string_literal: true

require_relative '../../info'

module INatGet::Data; end

class INatGet::Data::Model < Sequel::Model

  # @api private
  class << self

    def manager = raise NotImplementedError, "Not implemented method 'manager' in abstract class", caller_locations

    def helper = self.manager.helper

    def updater = self.manager.updater

    def parser = self.manager.parser

  end

end

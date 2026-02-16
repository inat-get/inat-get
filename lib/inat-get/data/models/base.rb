# frozen_string_literal: true

require_relative '../../info'

module INatGet::Data; end

class INatGet::Data::Model < Sequel::Model

  # @api private
  class << self

    def manager = nil

    def helper = self.manager&.helper

    def updater = self.manager&.updater

    def parser = self.manager&.parser

  end

end

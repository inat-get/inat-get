# frozen_string_literal: true

require_relative '../../info'

module INatGet::Data

  class Model < Sequel::Model
  # class Model < Sequel::Model

    # self.dataset = nil

    plugin :association_pks

    unrestrict_primary_key

    # @api private
    class << self

      def manager = nil

      def helper = self.manager&.helper

      def updater = self.manager&.updater

      def parser = self.manager&.parser

    end

  end

end


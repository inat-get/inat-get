# frozen_string_literal: true

require_relative '../../info'
require_relative '../../utils/simple_singular'

module INatGet::Data

  class Model < Sequel::Model
  # class Model < Sequel::Model

    # self.dataset = nil

    plugin :association_pks

    unrestrict_primary_key

    # @api private
    class << self

      # @private
      private def inner_key() = self.table_name

      def manager
        @manager ||= get_manager
      end

      # @private
      private def get_manager
        name = inner_key.to_s
        require_relative "../managers/#{ name }"
        cls = INatGet::Data::Manager.const_get name.capitalize
        cls&.instance
      end

      def parser
        @parser ||= get_parser
      end

      # @private
      private def get_parser
        name = inner_key.to_s.singular
        require_relative "../parsers/#{ name }"
        cls = INatGet::Data::Parser.const_get name.capitalize
        cls&.instance
      end

      def helper() = self.manager&.helper

      def updater() = self.manager&.updater

    end

  end

end

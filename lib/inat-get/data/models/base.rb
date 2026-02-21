# frozen_string_literal: true

require_relative '../../info'

module INatGet::Data

  Model = Class::new(Sequel::Model) do 
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

      def mk_apks
        # associations.each do |assoc|
        #   reflection = association_reflection(assoc)
        #   if [:one_to_many, :many_to_many].include?(reflection[:type])
        #     # association_pks assoc
        #   end
        # end
      end

    end

  end

end


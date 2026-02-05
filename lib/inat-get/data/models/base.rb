# frozen_string_literal: true

module INatGet::Data::Model::Base

  module Cls

    def manager = raise NorImplementedError, "Not implemented method 'manager' in abstract class", caller_locations

    def helper = self.manager.helper

    def updater = self.manager.updater

    def parser = self.manager.parser

  end

  class << self

    def included cls
      cls.extend INatGet::Data::Model::Base::Cls
    end

  end

end

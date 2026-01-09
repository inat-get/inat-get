# frozen_string_literal: true

require 'logger'
require 'sequel'

require 'is-dsl'

require_relative 'info'
require_relative '../app/setup'

module INatGet::Globals; end

module INatGet::Globals::Logging

  class << self

    def logger
      @logger ||= create_logger
    end

    def logger! **opts
      @logger = create_logger **opts
    end

    private

    def create_logger **opts
      config = ING::config[:logger].merge opts
      device = config.delete(:file) || config.delete(:device) || $stderr
      shift_age = config.delete(:shift_age)
      shift_size = config.delete(:shift_size)
      if shift_age
        Logger::new device, shift_age, **config
      elsif shift_size
        Logger::new device, nil, shift_size, **config
      else
        Logger::new device, **config
      end
    end

  end

end

module ING

  extend IS::DSL

  self >> INatGet::Globals::Logging

  encapsulate INatGet::Globals::Logging, :logger, :logger!

end

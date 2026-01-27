# frozen_string_literal: true

require_relative '../../info'

module INatGet::Actor; end

class INatGet::Actor::Core

  attr_reader :main, :config

  def initialize main, config
    @main = main
    @config = config
  end

  attr_reader :logger

  def execute
    require_relative 'logger'
    @logger = INatGet::System::MainLogger::new @main
    @logger.progname = self.name
  end

end

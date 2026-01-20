# frozen_string_literal: true

require_relative '../../info'

module INatGet::Actor; end

class INatGet::Actor::Core

  attr_reader :main, :config

  def initialize main, config
    @main = main
    @config = config
  end

  attr_reader :db

  def execute
  end

end


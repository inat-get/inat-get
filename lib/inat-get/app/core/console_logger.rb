# frozen_string_literal: true

require 'logger'

require_relative '../../info'

module INatGet::App; end

class INatGet::App::ConsoleLogger < Logger

  def initialize console, **options
    @console = console
    super(nil, **options)
  end

  def add severity, msg = nil, progname = nil
    return unless msg || block_given?
    msg = yield if block_given? && msg.nil?
    @console.log severity, msg, (progname || self.progname)
  end

end

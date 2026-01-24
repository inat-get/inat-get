# frozen_string_literal: true

require 'logger'

require_relative '../../info'

module INatGet::System; end

class INatGet::System::MainLogger < ::Logger

  def initialize main, **options
    @main = main
    super nil, **options
  end

  def add severity, msg = nil, progname = nil
    return unless msg || block_given?
    msg = yield if block_given? && msg.nil?
    @main.send({
      command: :log,
      data: {
        worker: Ractor.current,
        severity: severity,
        message: msg,
        progname: progname || self.progname
      }
    })
  end

end

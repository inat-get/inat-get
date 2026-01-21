# frozen_string_literal: true

require 'logger'

require_relative '../../info'

module INatGet::System; end

class INatGet::System::MainLogger < ::Logger

  def initialize main, **options
    @main = main
    super nil, **options
  end

  def add severity, time = Time.now, progname = nil, msg = nil
    return unless msg || block_given?
    msg = yield if block_given? && msg.nil?
    @main.send({
      command: :log,
      data: {
        severity: severity,
        time: time,
        progname: progname || self.progname,
        message: msg
      }
    })
  end

end

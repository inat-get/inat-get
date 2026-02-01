# frozen_string_literal: true

require_relative 'server'

class INatGet::Server::Console < INatGet::Server

  class << self

    def wait_answer?
      false
    end

  end

  # TODO: реализовать вывод состояний через is-term

  def initialize socket_path, **params
    super(socket_path, **params)
    # TODO: implement
  end

  def register **opts
    # TODO: implement
  end

  def update **opts
    # TODO: implement
  end

  def log severity, message, progname, **opts
    $stderr.puts "[ #{opts[:_sender_pid]} ] ( #{severity} ) #{message} || #{progname}"
    # TODO: implement
  end

end

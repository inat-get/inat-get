# frozen_string_literal: true

require 'logger'
require 'singleton'

require_relative '../info'
require_relative 'core/console'
require_relative 'core/api'
require_relative 'core/task'
require_relative 'core/worker'

class INatGet::Application

  # PROGRESS_TITLE = "🌿 \e[1miNatGet:\e[0m\e[K\tprocessing: \e[1m:current\e[0m of \e[1m:total\e[0m\ttotal time: \e[1m:elapsed\e[0m\tspeed: \e[1m:mean_rate\e[0m r/s \t:extra"
  # PROGRESS_LINE  = "\e[1m:title \e[K\t- :status - \t[:bar] :percent \t:current of :total \t:eta\e[0m \t:appendix"

  # private_constant :PROGRESS_TITLE, :PROGRESS_LINE

  include Singleton

  def initialize
    @config = INatGet::Setup::config!
    if @config[:tasks].nil?
      warn "❌ No tasks specified!"
      exit(-1)
    end
  end

  def run
    console_socket = @config.dig :socket, :console
    api_socket = @config.dig :socket, :api
    check_sockets! api_socket, console_socket

    if api_socket_exists?
      if api_socket_alive?
        warn "❌ API Socket already exists!"
        exit(-1)
      else
        File.delete @api_socket
      end
    end
    
    console = INatGet::Server::Console::create console_socket
    api = INatGet::Server::API::create api_socket, console: console

    tasks = @config[:tasks].map { |path| INatGet::Task::new path, @config }
    INatGet::Worker::enqueue @config, *tasks, console: console, api: api
  end

  private

  def check_sockets! socket, socket2
    if File.exist?(socket)
      if socket_alive?(socket)
        warn "❌ API Socket already exists!"
        exit(-1)
      end
    else
      File.delete socket
    end

    if File.exist?(socket2)
      File.delete socket2
    end
  end

  def socket_alive? socket
    return false unless File.socket?(socket)
    sock = UNIXSocket::new socket
    sock.close
    true
  rescue
    false
  end

end

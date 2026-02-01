# frozen_string_literal: true

require 'logger'
require 'singleton'

require_relative '../info'
require_relative 'core/console'
require_relative 'core/api'
require_relative 'core/task'
require_relative 'core/worker'

class INatGet::Application

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

    console = INatGet::Server::Console::create console_socket
    api = INatGet::Server::API::create api_socket, console: console

    tasks = @config[:tasks].map { |path| INatGet::Task::new path, @config }
    Process::warmup
    INatGet::Worker::enqueue @config, *tasks, console: console, api: api
    console.quit
    api.quit
  end

  private

  def check_sockets! socket, socket2
    if File.exist?(socket)
      if socket_alive?(socket)
        warn "❌ API Socket already exists!"
        exit(-1)
      else
        File.delete socket
      end
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

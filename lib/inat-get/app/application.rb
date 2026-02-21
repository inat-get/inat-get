# frozen_string_literal: true

require 'logger'
require 'singleton'

require_relative '../info'
require_relative 'core/console'
require_relative 'core/api'
require_relative 'core/task'
require_relative 'core/worker'

module INatGet::App; end

class INatGet::App::Main

  include Singleton

  def initialize
    @config = INatGet::App::Setup::config!
    if @config[:tasks].nil?
      warn "❌ No tasks specified!"
      exit Errno::ECHILD::Errno
    end
  end

  def run
    console_socket = @config.dig :socket, :console
    api_socket = @config.dig :socket, :api
    check_sockets! api_socket, console_socket

    INatGet::App::Maintenance::db_check @config, true

    console = INatGet::App::Server::Console::create console_socket
    api = INatGet::App::Server::API::create api_socket, console: console

    tasks = @config[:tasks].map { |path| INatGet::App::Task::new path, @config, console: console, api: api }
    Process::warmup
    INatGet::App::Worker::enqueue @config, *tasks, console: console, api: api
    console.quit
    api.quit
  end

  private

  def check_sockets! socket, socket2
    if File.exist?(socket)
      if socket_alive?(socket)
        warn "❌ API Socket already exists!"
        exit Errno::EEXIST::Errno
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
    INatGet::App::Server::used? socket
  end

end

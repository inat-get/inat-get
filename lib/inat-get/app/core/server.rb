# frozen_string_literal: true

require 'socket'
require 'fileutils'

require_relative '../../info'
require_relative '../setup'

module INatGet::App; end

class INatGet::App::Server 

  attr_reader :config

  def initialize socket_path, **params
    @socket_path = socket_path
    @params = params
    @config = ::INatGet::App::Setup::config
  end

  def run
    @server = ::UNIXServer::new @socket_path
    @server.listen 1024
    before_loop
    loop do
      client = @server.accept
      msg = ::Marshal.load client
      result = process_msg msg
      case result
      when nil
        # do nothing
      when :quit
        ::Marshal.dump result, client
        break
      else
        ::Marshal.dump result, client
      end
      client.close
    end
    after_loop
    @server.close
    ::File.delete @socket_path
  end

  private

  def process_msg msg
    method = msg[:method]
    return :quit if method == :quit
    return :pong if method == :ping
    args = msg[:args] || []
    kwargs = msg[:kwargs] || {}
    self.send method, *args, **kwargs
  rescue => e
    on_error e
  end

  protected

  def before_loop
    # do nothing by default
  end

  def after_loop
    # do nothing by default
  end

  def on_error exception
    warn exception
    warn exception.backtrace
  end

  class Proxy 

    def initialize detacher, socket_path, wait_answer = true
      @detacher = detacher
      @socket_path = socket_path
      @wait_answer = wait_answer
    end

    def close
      self.quit
      @detacher.join
    end

    def pid
      @detacher.pid
    end

    def alive?
      @detacher.alive?
    end

    def method_missing sym, *args, **kwargs
      kwargs[:_sender_pid] = ::Process::pid
      msg = {
        method: sym,
        args: args,
        kwargs: kwargs
      }
      socket = ::UNIXSocket::new @socket_path
      ::Marshal.dump msg, socket
      result = @wait_answer ? ::Marshal.load(socket) : true
      socket.close
      result
    rescue => e
      pp e
      false
    end

  end

  class << self

    def create socket_path, **params
      @proxies ||= {}
      raise ArgumentError, "Server already created: #{ socket_path }", caller_locations if @proxies.has_key?(socket_path)
      FileUtils.mkdir_p File.dirname(socket_path)
      pid = fork do
        server = new(socket_path, **params)
        server.run
      end
      detacher = Process::detach pid
      @proxies[socket_path] = INatGet::App::Server::Proxy::new(detacher, socket_path, wait_answer?)
      @proxies[socket_path]
    end

    def used? socket_path
      proxy = INatGet::App::Server::Proxy::new nil, socket_path, true
      proxy.ping == :pong
    rescue
      return false
    end

    private :new

    private

    def wait_answer?
      true
    end

  end

end

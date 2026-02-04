# frozen_string_literal: true

require 'sequel'

require_relative '../../info'
require_relative '../dsl'
require_relative 'console_logger'

class INatGet::Task

  include INatGet::DSL

  attr_reader :path, :name

  def initialize path, config, **opts
    @config = config
    @path = path
    @name = File.basename path, '.*'
    @opts = opts
    @console = opts[:console]
    inner_code = File.read @path
    outer_code = "define_singleton_method :execute do\n" +
                 "#{ inner_code }\n" +
                 "end\n"
    instance_eval outer_code
  end

  attr_reader :db

  def prepare
    db_connect = @config.dig(:database, :connect)
    db_options = { user: @config.dig(:database, :user), password: @config.dig(:database, :password) }.compact
    @db = Sequel::connect(db_connect, **db_options)
    Sequel::Model::db = @db
    require_relative '../../objects/observation'
    # # ... etc
  end

  private

  def logger
    @logger ||= INatGet::App::ConsoleLogger::new @console, progname: self.name
  end

end

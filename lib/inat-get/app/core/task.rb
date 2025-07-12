# frozen_string_literal: true

require 'sequel'
Sequel.extension :core_extensions
Sequel.datetime_class = DateTime
Sequel.database_timezone = :utc
Sequel.application_timezone = :local

require_relative '../../info'
require_relative '../../data/dsl/dsl'
require_relative 'console_logger'

class INatGet::App::Task

  include INatGet::Data::DSL

  attr_reader :path, :name

  def initialize path, config, **opts
    @config = config
    @path = path
    @name = File.basename path, '.*'
    @opts = opts
    @console = opts[:console]
    @api = opts[:api]
    inner_code = File.read @path
    outer_code = "define_singleton_method :execute do\n" +
                 "#{ inner_code }\n" +
                 "end\n"
    instance_eval outer_code
  end

  attr_reader :db

  def prepare
    Thread::current[:api] = @api
    Thread::current[:console] = @console
    Thread::current[:logger] = logger
    db_connect = @config.dig(:database, :connect)
    db_options = { user: @config.dig(:database, :user), password: @config.dig(:database, :password) }.compact
    @db = Sequel::connect(db_connect, **db_options)
    if @db.database_type == :sqlite
      @db.extend_datasets do
        def literal_datetime(value)
          "'#{value.iso8601}'"
        end
      end
      @db.execute 'PRAGMA journal_mode=WAL'
      @db.execute 'PRAGMA synchronous=NORMAL'
      @db.execute 'PRAGMA busy_timeout=5000'
    end
    Sequel::Model.require_valid_table = false
    Sequel::Model.strict_param_setting = false
    Sequel::Model.raise_on_save_failure = true
    Sequel::Model.db = @db
    Sequel::Model.db.loggers << ::Logger::new("debugdb.log", level: :debug)
    require_relative '../../data/models/observation'
    require_relative '../../data/managers/places'
    require_relative '../../data/managers/projects'
    require_relative '../../data/managers/users'
    require_relative '../../data/managers/taxa'
    require_relative '../../data/managers/observations'
    require_relative '../../data/managers/identifications'
    # # ... etc
  end

  private

  def logger
    @logger ||= INatGet::App::ConsoleLogger::new @console, progname: self.name
  end

end

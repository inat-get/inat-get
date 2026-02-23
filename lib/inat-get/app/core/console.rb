# frozen_string_literal: true

require 'logger'

require 'is-term/statustable'
require 'is-term/formats'
require 'is-term/functions'

require_relative 'server'

class INatGet::App::Server::Console < INatGet::App::Server

  def initialize socket_path, **params
    super(socket_path, **params)
    @table = IS::Term::StatusTable::instance
    @table.configure do
      column :icon, func: lambda { |row| row[:_active] ? "\e[1m[ ]" : "[✔]" }
      separator
      column :_sender_pid, id: true, align: :right
      separator
      column :name
      separator
      column :status, align: :center
      separator
      column :current, align: :right, summary: :current
      separator ' of '
      column :total, align: :left, summary: :total
      separator
      column :percent, align: :right, format: '%d%%', summary: :percent
      separator
      column :estimated, func: :estimated, align: :right, format: :duration, summary: :elapsed
      separator
      column :speed, func: :speed, format: '%.2f r/s', align: :right, summary: :speed
      separator
      column :message, summary: :value

      summary true, message: ''
    end
    if @config.dig(:logs, :file, :enable)
      filename = @config.dig(:logs, :file, :enable)
      @sys_logger = Logger::new filename, 'daily', 7, level: @config.dig(:logs, :file, :sys)
      @api_logger = Logger::new filename, 'daily', 7, level: @config.dig(:logs, :file, :api)
      @wrk_logger = Logger::new filename, 'daily', 7, level: @config.dig(:logs, :file, :wrk)
    end
    @log_levels = {
      sys: Logger::Severity::coerce(@config.dig(:logs, :screen, :sys)),
      api: Logger::Severity::coerce(@config.dig(:logs, :screen, :api)),
      wrk: Logger::Severity::coerce(@config.dig(:logs, :screen, :wrk))
    }
  end

  def register **opts
    @table.append(**opts)
  end

  def update **opts
    @table.update(**opts)
  end

  def log severity, message, progname, **opts
    key = prog_key progname
    pid = opts[:_sender_pid]
    console_log severity, message, progname, key, pid
    file_log severity, message, progname, key if @config.dig(:logs, :file, :enable)
    true
  end

  private

  def prog_key progname
    if progname.nil? || progname == ''
      :sys
    elsif progname == 'SYS' || progname == 'API'
      progname.downcase.to_sym
    else
      :wrk
    end
  end

  def file_log severity, message, progname, prog_key
    case prog_key
    when :api
      @api_logger.log severity, message, progname
    when :wrk 
      @wrk_logger.log severity, message, progname
    else
      @sys_logger.log severity, message, progname
    end
  end

  SEV_ICON = {
    Logger::Severity::DEBUG => '📓',
    Logger::Severity::INFO  => '📢',
    Logger::Severity::WARN  => '🔔',
    Logger::Severity::ERROR => '🚨',
    Logger::Severity::FATAL => '❌'
  }

  def console_log severity, message, progname, prog_key, pid
    if severity >= @log_levels[prog_key]
      if prog_key == :wrk
        @table.update _sender_pid: pid, message: "#{ SEV_ICON[severity] } #{ message }"
      else
        @table.summary message: "#{ SEV_ICON[severity] } [#{ progname }] #{ message }"
      end
    end
  end

end

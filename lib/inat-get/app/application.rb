# frozen_string_literal: true

require 'singleton'
require 'progress-bar'
require 'pastel'

require_relative '../info'
require_relative 'actors/api'
require_relative 'actors/worker'

class INatGet::Application

  PROGRESS_TITLE = "🌿 \e[1miNatGet:\e[0m\e[K\tprocessing: \e[1m:current\e[0m of \e[1m:total\e[0m\ttotal time: \e[1m:elapsed\e[0m\tspeed: \e[1m:mean_rate\e[0m r/s \t:extra"
  PROGRESS_LINE  = "\e[1m:title \e[K\t- :status - \t[:bar] :percent \t:current of :total \t:eta\e[0m \t:appendix"

  private_constant :PROGRESS_TITLE, :PROGRESS_LINE

  include Singleton

  def initialize
    @config = INatGet::Setup::config!
    if @config[:tasks].nil?
      warn "❌ No tasks specified!"
      exit -1
    end
    @config.freeze
  end

  def run
    main = Ractor.current

    api = Ractor::new(main, @config, name: 'API') do |main, config|
      actor = INatGet::Actor::API::new main, config
      actor.execute
    end

    tasks = @config[:tasks].map { |f| INatGet::Task::new(f) }
    case @config.dig(:workers, :order)
    when 'name', :name
      tasks.sort_by! { |t| t.name }
    when 'random', :random
      tasks.shuffle!
    end

    @multibar = TTY::ProgressBar::Multi::new PROGRESS_TITLE, width: 20
    @work_bars = {}
    @work_currents = {}

    loop do
      if tasks.empty? && Ractor.count == 2
        api.send({ command: :quit }.freeze)
        break
      end

      if !tasks.empty? && Ractor.count < @config.dig(:workers, :limit) + 2
        task = tasks.shift
        worker = Ractor::new(main, api, @config, task, name: task.name) do |main, api, config, task|
          actor = INatGet::Actor::Worker::new main, api, config, task
          actor.execute
        end
      end

      msg = Ractor.receive
      command = msg[:command]
      data = msg[:data].dup
      self.send command, data
    end
  end

  private

  def start data
    worker = data[:worker]
    bar = @multibar.register PROGRESS_LINE, width: 20, total: data[:total]
    @work_bars[worker] = bar
    @work_currents[worker] = {
      title: data[:title],
      status: 'started',
      current: nil,
      appendix: ''
    }
    bar.on :done do 
      bar.log "\e[K#{ data[:title] } \t- done - \t[≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡] [✔] \t#{ bar.current } of #{ bar.total } \t#{ TTY::ProgressBar::Converter.to_time(bar.elapsed_time) }" 
    end
  end

  def done data
    worker = data[:worker]
  end

  def severity_of device, subject
    @severities ||= {}
    @severities[device] ||= {}
    @severities[device][subject] ||= Logger::Severity::coerce(@config.dig(:logs, device, subject) || :unknown)
  end

  LOG_ICONS = {
    Logger::Severity::FATAL   => '❌',
    Logger::Severity::ERROR   => '🚨',
    Logger::Severity::WARN    => '🔔',
    Logger::Severity::INFO    => '📢',
    Logger::Severity::DEBUG   => '🔍',
    Logger::Severity::UNKNOWN => '🪲'
  }

  PASTEL = Pastel::new
  LOG_COLORS = {
    Logger::Severity::FATAL   => PASTEL.bright_red.on_magenta.detach,
    Logger::Severity::ERROR   => PASTEL.bright_red.detach,
    Logger::Severity::WARN    => PASTEL.bright_yellow.detach,
    Logger::Severity::INFO    => PASTEL.bright_white.detach,
    Logger::Severity::DEBUG   => PASTEL.bright_cyan.detach,
    Logger::Severity::UNKNOWN => PASTEL.red.on_bright_cyan.detach
  }

  def colorize severity, message, progname = nil
    LOG_COLORS[severity]["#{ LOG_ICONS } #{ progname ? "*#{ progname.uppercase }* " : '' }#{ message }"]
  end

  def logger
    @logger ||= Logger::new @config.dig(:logs, :file, :path), 'daily', level: Logger::DEBUG
  end

  def log data
    worker = data.delete :worker
    severity = data[:severity]
    message = data[:message]
    progname = data[:progname].to_s
    prog_key = progname.downcase.to_sym
    if worker && @work_bars[worker] && severity >= severity_of(:screen, :wrk)
      @work_currents[worker][:appendix] = colorize severity, message
      @work_bars[worker].advance 0, appendix: @work_currents[worker][:appendix]
      # @work_bars[worker].current = @work_currents[worker].current
    elsif [:sys, :api].include?(prog_key) && severity >= severity_of(:screen, prog_key)
      @multibar.top_bar.update extra: colorize(severity, message, progname)
    end
    if @config.dig(:logs, :file, :enabled)
      sev_key = [:sys, :api].include?(prog_key) ? prog_key : :wrk
      if severity >= severity_of(:file, sev_key)
        logger.log severity, message, progname
      end
    end
  end

  def status data
    worker = data.delete :worker
    @work_currents[worker].merge! data
    @work_bars[worker].advance(**@work_currents[worker])
  end

  def waiting data
    worker = data.delete :worker
    @work_bars[worker].log "\e[K#{ @work_currents[worker][:title] } \t- #{ data[:message] }"
  end

  def update data
    worker = data.delete :worker
    @work_bars[worker].update(**data)
    @multibar.top_bar.update total: @multibar.total if data.has_key?(:total)
  end

end

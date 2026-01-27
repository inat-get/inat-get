# frozen_string_literal: true

require_relative 'server'

class INatGet::Server::Console < INatGet::Server

  class << self

    def wait_answer?
      false
    end

  end

  PROGRESS_TITLE = "🌿 \e[1miNatGet:\e[0m\e[K\tprocessing: \e[1m:current\e[0m of \e[1m:total\e[0m\ttotal time: \e[1m:elapsed\e[0m\tspeed: \e[1m:mean_rate\e[0m r/s \t:extra"
  PROGRESS_LINE  = "\e[1m:title \e[K\t- :status - \t[:bar] :percent \t:current of :total \t:eta\e[0m \t:appendix"

  def initialize socket_path, **params
    super(socket_path, **params)
    require 'tty/progressbar'
    require 'tty/progressbar/multi'
    require 'pastel'
    @multibar = TTY::ProgressBar::Multi::new PROGRESS_TITLE, width: 20
    @data = {}
    @bars = {}
  end

  def register **opts
    sender_pid = opts.delete :_sender_pid
    @data[sender_pid] = opts
    @bars[sender_pid] = @multibar.register(PROGRESS_LINE, status: 'started', **opts)
  end

  def advance **opts
    sender_pid = opts.delete :_sender_pid
    @data[sender_pid] ||= {}
    @data[sender_pid].merge! opts
    if @bars[sender_pid]
      @bars[sender_pid].advance(**@data[sender_pid])
    else
      # TODO: logging
    end
  end

  def update **opts
    sender_pid = opts.delete :_sender_pid
    if @bars[sender_pid]
      @bars[sender_pid].update(**opts)
      if opts.has_key?(:total)
        @multibar.top_bar.update total: @multibar.total
      end
    end
  end

end

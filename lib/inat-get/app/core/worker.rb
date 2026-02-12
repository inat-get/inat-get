# frozen_string_literal: true

require_relative 'task'
require_relative 'console_logger'

class INatGet::App::Worker

  def initialize task, **params
    @task = task
    @params = params
    @console = params.delete :console
    @logger = INatGet::App::ConsoleLogger::new @console, progname: task.name
  end

  def execute
    @console.register status: 'started...', name: @task.name
    @task.prepare
    @task.execute
    @console.update _active: false
  rescue => e
    @logger.error e.message
  end

  class << self

    def create task, **params
      @detachers ||= []
      pid = fork do
        worker = new(task, **params)
        worker.execute
      end
      result = Process::detach pid
      @detachers << result
      result
    end

    private :new

    def count
      @detachers ||= []
      @detachers.reject { |dt| !dt.alive? }
      @detachers.size
    end

    def enqueue config, *tasks, **params
      queue = tasks.dup
      while queue.size > 0
        if self.count >= config.dig(:workers, :limit)
          sleep 0.01
          next
        end
        task = queue.shift
        self.create task, **params
        sleep 0.01
      end
      @detachers.map(&:join)
    end

  end

end

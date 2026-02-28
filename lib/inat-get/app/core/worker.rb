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
    require_relative '../../sys/context'
    Signal::trap(:TERM) { INatGet::System::Context::shutdown = true }
    Signal::trap(:INT)  { INatGet::System::Context::shutdown = true }
    @console.register status: 'started...', name: @task.name
    @task.prepare
    @task.execute
    @console.update _active: false, status: 'done'
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
      @shutdown = false
      Signal::trap(:TERM) { @shutdown = true }
      Signal::trap(:INT)  { @shutdown = true }
      queue = tasks.dup
      while queue.size > 0 && !@shutdown
        if self.count >= config.dig(:workers, :limit)
          sleep 0.1
          next
        end
        task = queue.shift
        self.create task, **params
        sleep 0.1
      end
      if @shutdown
        @detachers.each do |dt|
          if dt.alive?
            begin
              Process::kill :TERM, dt.pid
            rescue Errno::ESRCH
            end
          end
        end
        @detachers.each do |dt|
          dt.join 0.5
          if dt.alive?
            begin
              Process::kill :KILL, dt.pid
            rescue Errno::ESRCH
            end
          end
        end
      else
        @detachers.map(&:join)
      end
    end

  end

end

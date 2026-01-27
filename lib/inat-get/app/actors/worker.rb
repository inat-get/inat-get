# frozen_string_literal: true

require_relative 'core'

class INatGet::Actor::Worker < INatGet::Actor::Core

  attr_reader :api, :task, :name

  def initialize main, api, config, task
    super main, config
    @api = api
    @task = task
    @name = task.name
  end

  def execute
    super
    require "sequel"
    db_opts = { user: @config.dig(:database, :user), password: @config.dig(:database, :password) }.compact
    @db = Sequel.connect @config.dig(:database, :connect), **db_opts
    Sequel::Model.db = @db
    require_relative '../../objects/request'
    require_relative '../../objects/observation'
    
    msg = {
      command: :start,
      data: {
        worker: Ractor.current,
        title: @name
      }
    }
    @main.send msg

    @task.execute

  ensure
    msg = {
      command: :done,
      data: {
        worker: Ractor.current
      }
    }
    @main.send msg
  end

end

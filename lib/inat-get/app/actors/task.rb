# frozen_string_literal: true

require_relative 'core'

class INatGet::Actor::Task < INatGet::Actor::Core

  attr_reader :api, :task

  def initialize main, api, config, task
    super main, config
    @api = api
    @task = task
  end

  def execute
    super
    require "sequel"
    db_opts = { user: @config.dig(:database, :user), password: @config.dig(:database, :password) }.compact
    @db = Sequel.connect @config.dig(:database, :connect), **db_opts
    Sequel::Model.db = @db
    require_relative "../../objects/observation"
    # TODO: implement
  end

end

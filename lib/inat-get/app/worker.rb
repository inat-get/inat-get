# frozen_string_literal: true

require_relative '../info'

module INatGet::App; end

class INatGet::App::Worker

  def initialize api, config
    @api = api
    @config = config
  end

  def start
    this = Ractor.current
    Ractor.new this, api, config do |main, api, config|
      # TODO: implement
    end
  end

end

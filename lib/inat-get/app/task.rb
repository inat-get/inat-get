# frozen_string_literal: true

require_relative '../info'

class INatGet::Task

  attr_reader :name

  def initialize filename
    @filename = filename
    @name = File.basename filename, '.*'
  end

  def run
    #
  end

end


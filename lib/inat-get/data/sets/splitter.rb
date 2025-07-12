# frozen_string_literals: true

require_relative '../../core'

class INatGet::Splitter

  class << self

    def define name, item_type, key_type, &block
      @@splitters ||= {}
      @@splitters[name] = new(name, key_type, item_type, block)
    end

    def [] name
      @@splitters ||= {}
      @@splitters[name]
    end

    private :new

  end

  attr_reader :name, :key_type, :value_type, :function

  def initialize name, key_type, value_type, function
    @name = name
    @key_type = key_type
    @value_type = value_type
    @function = function
  end

  def call item
    @function.call(item)
  end

end

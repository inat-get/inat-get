# frozen_string_literal: true

require_relative '../info'

class INatGet::List

  def initialize *args
    @items = {}
    args.each do |arg|
      if arg.is_a?(Hash)
        @items.merge! arg
      else
        @items[arg.key] = arg
      end
    end
  end

  def copy
    INatGet::List::new @items
  end

  def keys
    @items.keys
  end

  def values 
    @items.values
  end

  def add! other
    other.values.each do |item|
      key = item.key
      if @items.has_key?(key)
        @items[key] += item
      else
        @items[key] = item
      end
    end
    self
  end

  def mul! other
    result = {}
    other.values.each do |item|
      key = item.key
      if @items.has_key?(key)
        result[key] = @items[key] + item
      end
    end
    @items = result
    self
  end

  def sub! other
    other.values.each do |item|
      key = item.key
      @items.delete key
    end
    self
  end

  def add other
    copy.add! other
  end

  def mul other
    copy.mul! other
  end

  def sub other
    copy.sub! other
  end

  alias + add
  alias * mul
  alias - sub

  include Enumerable

  def each
    return to_enum(__method__) unless block_given?
    @items.each do |_, value|
      yield value
    end
  end

  def to_h
    @items.dup
  end

  def to_a
    @items.values.dup
  end

end

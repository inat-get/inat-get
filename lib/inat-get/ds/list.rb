# frozen_string_literal: true

require_relative '../info'
require_relative '../condition'

class INatGet::List

  def initialize *datasets
    @datasets = {}
    datasets.each do |ds|
      @datasets[ds.key] = ds
    end
  end

  def keys
    @datasets.keys
  end

  def datasets
    @datasets.values
  end

  def [] key
    @datasets[key]
  end

  def copy
    INatGet::List::new *@datasets.values
  end

  def add! other
    other.each do |ds|
      if @datasets.has_key?(ds.key)
        @datasets[ds.key] += ds
      else
        @datasets[ds.key] = ds
      end
    end
    self
  end

  def mul! other
    result = {}
    case other
    when INatGet::List
      other.each do |ds|
        sds = @datasets[ds.key]
        if sds
          result[ds.key] = sds + ds
        end
      end
    when Enumerable
      other.each do |key|
        sds = @datasets[key]
        if sds
          result[key] = sds
        end
      end
    end
    @datasets = result
    self
  end

  def sub! other
    case other
    when INatGet::List
      other.each do |ds|
        @datasets.delete ds.key
      end
    when Enumerable
      other.each do |key|
        @datasets.delete key
      end
    end
    self
  end

  def + other
    copy.add! other
  end

  def * other
    copy.mul! other
  end

  def - other
    copy.sub! other
  end

  include Enumerable

  def values
    @datasets.values
  end

  def each
    return to_enum(__method__) unless block_given?
    @datasets.each do |_, ds|
      yield ds
    end
  end

  def filter!
    if block_given?
      @datasets.filter! do |_, value|
        yield value
      end
    end
    self
  end

  def filter_keys!
    if block_given?
      @datasets.filter! do |key, _|
        yield key
      end
    end
    self
  end

  def filter &block
    return to_enum(__method__) unless block_given?
    copy.filter! &block
  end

  def filter_keys &block
    return to_enum(__method__) unless block_given?
    copy.filter_keys! &block
  end

  def has_key? key
    @datasets.has_key? key
  end

  def size
    @datasets.size
  end

  def empty?
    @datasets.empty?
  end

  def to_a
    @datasets.values
  end

  def to_h
    @datasets.dup
  end

  def to_ds
    result = INatGet::Dataset::new(nil, NOTHING, true)
    @datasets.each do |_, ds|
      result += ds
    end
    result
  end

end

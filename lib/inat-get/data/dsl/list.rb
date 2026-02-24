# frozen_string_literal: true

require_relative '../../info'
require_relative 'conditions'

class INatGet::Data::DSL::List

  include INatGet::Data::DSL

  # @private
  def initialize *datasets
    @datasets = {}
    datasets.each do |ds|
      @datasets[ds.key] = ds
    end
  end

  # @group Enumerable

  # @return [Array<Object>]
  def keys
    @datasets.keys
  end

  # @return [Dataset, nil]
  def [] key
    @datasets[key]
  end

  # @endgroup

  # @private
  private def copy
    INatGet::Data::DSL::List::new(*@datasets.values)
  end

  # @group Data Access

  # @return [Array<Dataset>]
  def datasets
    @datasets.values
  end

  # @return [self]
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

  # @return [self]
  def mul! other
    result = {}
    case other
    when INatGet::Data::DSL::List
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

  # @return [self]
  def sub! other
    case other
    when INatGet::Data::DSL::List
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

  # @return [Dataset]
  def to_dataset
    result = INatGet::Data::DSL::Dataset::new(nil, NOTHING, true)
    @datasets.each do |_, ds|
      result += ds
    end
    result
  end

  # @endgroup

  # @group Operators

  # @return [List]
  def + other
    copy.add! other
  end

  # @return [List]
  def * other
    copy.mul! other
  end

  # @return [List]
  def - other
    copy.sub! other
  end

  # @endgroup

  include Enumerable

  # @group Enumerable

  # @return [void]
  # @yield Block
  # @yieldparam [Dataset] ds
  def each
    return to_enum(__method__) unless block_given?
    @datasets.each do |_, ds|
      yield ds
    end
  end

  # @return [Integer]
  def count
    @datasets.count
  end

  alias :size :count

  # @yield Boolean expression
  # @yieldparam [Dataset] ds
  # @return [self]
  def filter!
    if block_given?
      @datasets.filter! do |_, value|
        yield value
      end
    end
    self
  end

  # @yield Boolean expression
  # @yieldparam [Object] key
  # @return [self]
  def filter_keys!
    if block_given?
      @datasets.filter! do |key, _|
        yield key
      end
    end
    self
  end

  # @yield Boolean expression
  # @yieldparam [Dataset] ds
  # @return [List]
  def filter &block
    return to_enum(__method__) unless block_given?
    copy.filter!(&block)
  end

  # @yield Boolean expression
  # @yieldparam [Object] key
  # @return [List]
  def filter_keys &block
    return to_enum(__method__) unless block_given?
    copy.filter_keys!(&block)
  end

  def has_key? key
    @datasets.has_key? key
  end

  def empty?
    @datasets.empty?
  end

  alias :to_a :datasets
  alias :values :datasets

  # @return [Hash]
  def to_h
    @datasets.dup
  end

  # @group Operators

  # @return [List]
  def self.commons num, *src
    keys = {}
    values = {}
    src.each do |s|
      s.each do |value|
        key = value.key
        if value
          keys[key] ||= 0
          keys[key] += 1
          values[key] ||= []
          values[key] << value
        end
      end
    end
    selected_keys = keys.select { |_, value| value >= num }.keys
    result = new
    values.slice(*selected_keys).each_value do |value|
      result.add! value.reduce(:+)
    end
    result
  end

  # @endgroup

end

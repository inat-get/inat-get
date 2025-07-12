# frozen_string_literals: true

require_relative '../../core'
require_relative 'dataset'

class INatGet::List

  class << self

    # @!group Constructors

    # @param [Splitter] splitter
    # @return [List]
    def zero splitter
      new nil, splitter
    end

    # @!endgroup

  end

  include Enumerable

  # @!group Attributes

  # @return [Dataset, Enumerable, nil]
  attr_reader :source

  # @return [Splitter]
  attr_reader :splitter

  # @return [Module]
  attr_reader :key_type, :value_type

  # @!endgroup

  # @!group Constructors

  def initialize source, splitter
    @source = source
    @splitter = splitter
    @key_type = @splitter.key_type
    @value_type = @splitter.value_type
    # TODO: в зависимости от типа source устанавливать @data и @fetched
  end

  # @!endgroup

  # @!group Set Operators

  # @return [List]
  def union other
    # TODO: implement
  end

  # @return [List]
  def intersection other
    # TODO: implement
  end

  # @return [List]
  def difference other
    # TODO: implement
  end

  # @return [self]
  def union! other
    # TODO: implement
    self
  end

  # @return [self]
  def intersection! other
    # TODO: implement
    self
  end

  # @return [self]
  def difference! other
    # TODO: implement
    self
  end

  alias :+ :union
  alias :* :intersection
  alias :- :difference

  # @!endgroup

  # @!group Data Manipulation

  # @return [List]
  def where **query, &block
    # TODO: implement
  end

  # @return [self]
  def where! **query, &block
    # TODO: implement
    self
  end

  alias :filter :where
  alias :filter! :where!

  # @return [List]
  # @overload exclude(items)
  # @overload exclude(**query, &block)
  def exclude items = nil, **query, &block
    # TODO: implement
  end

  # @return [self]
  # @overload exclude!(items)
  # @overload exclude!(**query, &block)
  def exclude! items = nil, **query, &block
    # TODO: implement
    self
  end

  # @return [List]
  # @overload append(items)
  # @overload append(**query, &block)
  def append items = nil, **query, &block
    # TODO: implement
  end

  # @return [self]
  # @overload append!(items)
  # @overload append!(**query, &block)
  def append! items = nil, **query, &block
    # TODO: implement
    self
  end

  # @return [self]
  def << items
    append! items
  end

  # @!endgroup

  # @!group Enumerable Implementation

  def each &block
    # TODO: implement
  end

  # @return [Boolean]
  def empty?
    # TODO: implement
  end

  # @return [Boolean]
  def has_key? key
    # TODO: implement
  end

  # @return [Dataset]
  def [] key
    # TODO: implement
  end

  # @!endgroup

  # @!group Conversions

  # @return [Hash]
  def to_h
    fetch!
    # TODO: implement
  end

  # @return [Dataset]
  def to_dataset
    # TODO: implement
  end

  # @!endgroup

end

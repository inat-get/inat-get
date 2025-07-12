# frozen_string_literals: true

require_relative '../../core'

class INatGet::Dataset

  class << self

  # @!group Constructors

    # @return [Dataset]
    def zero item_type
      new(nil, item_type)
    end

  end

  # @!endgroup

  include Enumerable

  # @!group Attributes

  # @return [Class, Dataset, nil]
  attr_reader :source

  # @return [Hash]
  attr_reader :query

  # @return [Proc]
  attr_reader :block

  # @return [Module]
  attr_reader :item_type

  # @!endgroup

  # @!group Constructors

  def initialize source, item_type = nil, **query, &block
    # TODO: implement
  end

  # @!endgroup

  # @!group Set Operators

  # @return [Dataset]
  def union other
    # TODO: implement
  end

  # @return [Dataset]
  def intersection other
    # TODO: implement
  end

  # @return [Dataset]
  def difference other
    # TODO: implement
  end

  # @return [self]
  def union! other
    # TODO: implement
  end

  # @return [self]
  def intersection! other
    # TODO: implement
  end

  # @return [self]
  def difference! other
    # TODO: implement
  end

  alias :+ :union
  alias :* :intersection
  alias :- :difference

  # @!endgroup

  # @!group Data Manipulation

  # @return [Dataset]
  def and **query, &block
    # TODO: implement
  end

  alias :where :and

  # @return [Dataset]
  def or **query, &block
    # TODO: implement
  end

  # @return [Dataset]
  # @overload exclude(items)
  # @overload exclude(**query, &block)
  def exclude items = nil, **query, &block
    # TODO: implement
  end

  # @return [self]
  def and! **query, &block
    # TODO: implement
  end

  # @return [self]
  def or! **query, &block
    # TODO: implement
  end

  # @return [self]
  # @overload exclude!(items)
  # @overload exclude!(**query, &block)
  def exclude! items = nil, **query, & block
    # TODO: implement
  end

  alias :filter :and
  alias :filter! :and!

  # @return [Dataset]
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
  end

  # @return [self]
  def << items
    append! items
  end

  # @!endgroup

  # @!group Enumerable Implementation

  def each &block
    fetch!
    # TODO: implement
  end

  def empty?
    fetch!
    # TODO: implement
  end

  # @!endgroup

  # @!group Data Control

  def fetched?
    # TODO: implement
  end

  # @return [self]
  def fetch!
    # TODO: implement
  end

  # @!endgroup

  # @!group Conversions

  # @return [Array]
  def to_a
    fetch!
    # TODO: implement
  end

  # @return [List]
  def split splitter
    # TODO: implement
  end

  alias :% :split

  # @!endgroup

end

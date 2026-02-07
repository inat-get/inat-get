# frozen_string_literal: true

require_relative '../../info'
require_relative 'conditions'

class INatGet::Data::DSL::Dataset

  include INatGet::Data::DSL

  # @group Attributes

  # @return [Object, nil]
  attr_reader :key
  
  # @return [Condition]
  attr_reader :condition

  # @endgroup

  # @private
  def initialize key, condition, updated = false
    @key = key
    @condition = condition
    @updated = updated
  end

  # @group Methods

  def updated?
    @updated
  end

  # @return [self]
  def update!
    return self if @updated
    # TODO: implement
    @updated = true
    self
  end

  def connected?
    !!@dataset
  end

  # @return [self]
  def connect!
    return self if connected?
    update!
    @dataset = @condition.model.where @condition.to_sequel
    self
  end

  # @return [self]
  def reset!
    @updated = false
    @dataset = nil
    self
  end

  # @endgroup

  # @group Operators

  # @return [Dataset]
  def + other
    INatGet::Data::DSL::Dataset::new(self.key, self.condition | other.condition, self.updated? && other.updated?)
  end

  # @return [Dataset]
  def * other
    INatGet::Data::DSL::Dataset::new(self.key, self.condition & other.condition, self.updated? || other.updated?)
  end

  # @return [Dataset]
  def - other
    INatGet::Data::DSL::Dataset::new(self.key, self.condition & !other.condition, self.updated?)
  end

  # @return [List]
  def % field
    field = field.to_sym
    values = get_field_values field
    dss = values.map do |value|
      query = Q(self.model, field => value )
      INatGet::Data::DSL::Dataset::new(value, self.condition & query, self.updated?)
    end
    INatGet::Data::DSL::List::new(*dss)
  end

  # @return [Dataset]
  def where condition = nil, **query
    condition ||= ANYTHING
    condition &= Q(self.model, **query)
    INatGet::Data::DSL::Dataset::new(self.key, self.condition & condition, self.updated?)
  end

  # @endgroup

  include Enumerable

  # @group Enumerable

  # @yield Block
  # @yieldparam [Sequel::Model] obj
  # @return [void]
  def each &block
    return to_enum(__method__) unless block_given?
    connect!
    @dataset.each(&block)
  end

  # @return [Integer]
  def count
    connect!
    @dataset.count
  end

  # @endgroup

  private

  # @private
  def get_field_values field
    update!
    @condition.helper.model.select(field).where(@condition.sequel_query).all
  end

end

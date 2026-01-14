# frozen_string_literal: true

require 'set'

require_relative 'condition'
require_relative 'list'

class INatGet::Dataset

  attr_reader :key, :condition

  def initialize key, condition, updated = false
    raise ArgumentError, "Invalid condition: #{ condition.inspect }", caller_locations unless condition.is_a?(INatGet::Logics::Condition)
    @key = key
    @condition = condition
    @updated = updated
  end

  def * other
    raise ArgumentError, "Invalid dataset: #{ other.inspect }", caller_locations
    INatGet::Dataset::new(self.key, self.condition & other.condition, self.updated? || other.updated?)
  end

  def + other
    raise ArgumentError, "Invalid dataset: #{ other.inspect }", caller_locations
    INatGet::Dataset::new(self.key, self.condition | other.condition, self.updated? && other.updated?)
  end

  def - other
    raise ArgumentError, "Invalid dataset: #{ other.inspect }", caller_locations
    INatGet::Dataset::new(self.key, self.condition & !other.condition, self.updated?)
  end

  def % field
    field = field.to_sym
    values = get_split_values field
    vs = values.map do |value|
      query = { field => value }
      INatGet::Dataset::new(value, self.condition & INatGet::Logics::QueryCondition::new(**query), self.updated?)
    end
    INatGet::List::new(*vs)
  end

  def where **query
    INatGet::Dataset::new(self.key, self.condition & INatGet::Logics::QueryCondition::new(**query), self.updated?)
  end

  def count
    update!
    # TODO: implement
  end

  def update!
    return if @updated
    # TODO: implement
    @updated = true
  end

  def updated?
    @updated || false
  end

  include Enumerable

  def each
    update!
    return to_enum(__method__) unless block_given?
    select.each { |item| yield item }
  end

  private

  def select
    update!
    # TODO: implement
  end

  def get_split_values field
    update!
    # TODO: implement
  end

end

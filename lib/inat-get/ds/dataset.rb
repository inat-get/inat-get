# frozen_string_literal: true

require_relative '../info'
require_relative '../condition'

class INatGet::Dataset

  include INatGet::Condition

  attr_reader :key, :condition

  def initialize key, condition, updated = false
    @key = key
    @condition = condition
    @updated = updated
  end

  def helper
    @condition.helper
  end

  def updated?
    @updated
  end

  def update!
    return self if @updated
    # TODO: implement
    @updated = true
    self
  end

  def + other
    INatGet::Dataset::new(self.key, self.condition | other.condition, self.updated? && other.updated?)
  end

  def * other
    INatGet::Dataset::new(self.key, self.condition & other.condition, self.updated? || other.updated?)
  end

  def - other
    INatGet::Dataset::new(self.key, self.condition & !other.condition, self.updated?)
  end

  def % field
    field = field.to_sym
    values = get_field_values field
    dss = values.map do |value|
      query = Q[self.helper][ field => value ]
      INatGet::Dataset::new(value, self.condition & query, self.updated?)
    end
    INatGet::List::new(*dss)
  end

  def where condition = nil, **query
    condition ||= ANYTHING
    condition &= Q[self.helper][**query]
    INatGet::Dataset::new(self.key, self.condition & condition, self.updated?)
  end

  include Enumerable

  def each
    # TODO: implement
  end

  def count
    # TODO: implement
  end

  private

  def get_field_values field
    # TODO: implement
  end

end

# frozen_string_literal: true

require_relative '../../info'
require_relative 'conditions'
require_relative '../../sys/context'
require_relative 'list'

class INatGet::Data::DSL::Dataset

  include INatGet::Data::DSL
  include INatGet::System::Context

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
    updater = @condition.manager.updater
    updater.update! @condition
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
    @dataset = @condition.model.where @condition.sequel_query
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
      query = Q(self.condition.model, field => value )
      INatGet::Data::DSL::Dataset::new(value, self.condition & query, self.updated?)
    end
    INatGet::Data::DSL::List::new(*dss)
  end

  # @return [Dataset]
  def where condition = nil, **query
    condition ||= ANYTHING
    condition &= Q(@condition.model, **query)
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
    @dataset.each do |item|
      check_shutdown!
      block.call item
    end
  end

  # @return [Integer]
  def count
    connect!
    @dataset.count
  end

  # @endgroup

  private

  # @private
  def get_field_values(field)
    update!
    model = @condition.model
    query = model.where(@condition.sequel_query)

    if model.associations.include?(field)
      reflection = model.association_reflection(field)
      target = reflection.associated_class

      case reflection[:type]
      when :many_to_one
        ids = query.distinct.select_map(reflection[:key])
        target.where(id: ids).all
      when :one_to_many, :many_to_many
        # Для всех типов "много" используем ассоциативный датасет
        # association_join делает join на основе метаданных связи
        ids = query.association_join(field)
                   .distinct
                   .select_map(reflection.qualified_right_key)
        target.where(id: ids).all
      end
    else
      # field может быть как символом :column, так и Sequel.function(:month, :created_at)
      query.distinct.select_map(field)
    end
  end

end

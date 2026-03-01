# frozen_string_literal: true

require_relative '../../info'

module INatGet::Data; end

# @api private
class INatGet::Data::Helper

  UUID_PATTERN = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/

  # @group Must be implemented in descendants

  # @return [INatGet::Data::Manager]
  def manager() = raise NotImplementedError, "Not implemented method 'manager' in abstract class", caller_locations

  # @return [Symbol]
  def endpoint() = self.manager.endpoint

  # @endgroup

  # @group Interface

  # @return [Hash]
  def prepare_query **query
    # Вызывается в процессе нормализации условий — ДО преобразований для API и Sequel
    # Выполняем слеюущие преобразования
    #   - Date и диапазоны Date — в диапазоны Time
    #   - Одиночные значения там, где допустим перечень — в Set
    #   - Диапазоны Rank — в Set<Rank>
    #   - Широта, долгота и Location — в диапазоны широты и долготы
    #   - Символы в строки
    # Модели в примитивы на этом этапе НЕ преобразуем, тем более не преобразуем данные между полями.
    result = {}
    defs = self.definitions
    query.each do |key, value|
      definition = defs[key]
      raise KeyError, "Invalid query key: #{ key }", caller_locations if definition.nil?
      prepared = definition.prepare value
      if prepared.is_a?(Hash)
        result.merge! prepared
      else
        result[key] = prepared
      end
    end
    result
  end

  # Raises exception if any field is not valid.
  # @return [Boolean]
  def validate_query! **query
    defs = self.definitions
    query.each do |key, value|
      definition = defs[key]
      raise KeyError, "Invalid query key: #{ key }", caller_locations if definition.nil?
      raise ArgumentError, "Invalid query value: #{ key } => #{ value.inspect }" unless definition.valid?(value)
    end
  end

  # Array of request definitions
  # @return [Array<Hash>]
  def query_to_api **query
    # default implementation
    defs = self.definitions
    converted = {}
    query.each do |key, value|
      definition = defs[key]
      raise KeyError, "Invalid query key: #{ key }", caller_locations if definition.nil?
      converted_value = definition.to_api value
      if converted_value.is_a?(Hash)
        converted.merge! converted_value
      else
        converted[key] = converted_value
      end
    end
    [ { endpoint: manager.endpoint, query: converted } ]
  end

  # @return [Sequel::SQL::Expression]
  def query_to_sequel **query
    # default implementation
    defs = self.definitions
    sequel_terms = []
    query.each do |key, value|
      definition = defs[key]
      raise KeyError, "Invalid query key: #{ key }", caller_locations if definition.nil?
      sequel_terms << definition.to_sequel(value)
    end
    Sequel.&(*sequel_terms)
  end

  # @endgroup

  class << self

    # @group Definitions DSL

    # @return [Field]
    def field key, cls, *args
      raise ArgumentError, "Invalid field key: #{ key.inspect }", caller_locations unless key.is_a?(Symbol)
      raise ArgumentError, "Invalid field class: #{ cls.inspect }", caller_locations unless cls.is_a?(Class) && cls < INatGet::Data::Helper::Field
      @fields ||= {}
      @fields[key] = cls.new(self.instance, key, *args)
    end

    # @return [Hash<Field>]
    def fields
      @fields ||= {}
    end

    # @endgroup

  end

  # @group Definitions DSL

  # @return [Hash<Field>]
  def definitions() = self.class.fields

  # @endgroup

end

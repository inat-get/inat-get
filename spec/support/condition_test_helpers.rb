# frozen_string_literal: true

require 'singleton'
require "sequel"
require "set"

require_relative '../../lib/inat-get/data/helpers/base'
require_relative '../../lib/inat-get/data/helpers/defs'

# Общие хелперы для тестирования Condition классов
module ConditionTestHelpers
  # Создает тестовую модель с минимальным хелпером
  def test_model
    @test_model ||= begin
        db = Sequel.mock
        Sequel::Model.db = db

        # Создаем анонимный класс модели
        model = Class.new(Sequel::Model(:test_table)) do
          def self.name
            "TestModel"
          end

          def self.helper
            @helper ||= TestHelper.instance
          end
        end

        # Устанавливаем primary key для тестов
        model.unrestrict_primary_key
        model
      end
  end

  # Создает Query условие с заданными параметрами
  def query(**params)
    model = test_model
    INatGet::Data::DSL::Condition::Query[model, **params]
  end

  # Хелпер класс для тестов
  class TestHelper < INatGet::Data::Helper
    include Singleton

    def manager
      @manager ||= TestManager.instance
    end

    def definitions
      @definitions ||= {
        id: TestField::Ids.new(self, :id),
        name: TestField::Scalar.new(self, :name, String),
        status: TestField::Set.new(self, :status, String),
        value: TestField::Range.new(self, :value, Integer),
      }
    end

    def prepare_query(**query)
      result = {}
      query.each do |key, value|
        field = definitions[key]
        raise KeyError, "Unknown field: #{key}" unless field
        result[key] = field.prepare(value)
      end
      result
    end

    def query_to_api(**query)
      [{ endpoint: :test, query: query }]
    end

    def query_to_sequel(**query)
      Sequel.&(*query.map { |k, v| { k => v } })
    end
  end

  # Тестовый менеджер
  class TestManager
    include Singleton

    def endpoint
      :test
    end

    def helper
      TestHelper.instance
    end

    def model
      TestModel
    end
  end

  # Базовый класс для тестовых полей
  module TestField
    class Base < INatGet::Data::Helper::Field
      def initialize(helper, key)
        super
      end

      # Добавляем недостающий метод valid?
      def valid?(value)
        true # По умолчанию принимаем любое значение
      end
    end

    class Ids < Base
      def prepare(value)
        case value
        when nil then nil
        when Integer, String then ::Set[value]
        when Enumerable then value.to_set
        else raise ArgumentError
        end
      end

      def valid?(value)
        value.nil? || value.is_a?(Integer) || value.is_a?(String) ||
          value.is_a?(Enumerable) || value.is_a?(Set)
      end
    end

    class Scalar < Base
      def initialize(helper, key, check)
        super(helper, key)
        @check = check
      end

      def prepare(value)
        value
      end

      def valid?(value)
        value.nil? || @check === value
      end
    end

    class Set < Base
      def initialize(helper, key, check)
        super(helper, key)
        @check = check
      end

      def prepare(value)
        case value
        when nil then nil
        when ::Set then value
        when Enumerable then value.to_set
        else ::Set[value]
        end
      end

      def valid?(value)
        return true if value.nil?
        return true if value.is_a?(::Set)
        return true if value.is_a?(@check)
        return true if value.is_a?(Enumerable)
        false
      end
    end

    class Range < Base
      def initialize(helper, key, check)
        super(helper, key)
        @check = check
      end

      def prepare(value)
        case value
        when nil then nil
        when ::Range then value
        when @check then (value..value)
        else raise ArgumentError
        end
      end

      def valid?(value)
        return true if value.nil?
        return true if value.is_a?(::Range)
        return @check === value
      end
    end
  end
end

RSpec.configure do |config|
  config.include ConditionTestHelpers
end

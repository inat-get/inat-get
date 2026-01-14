# frozen_string_literal: true

require_relative 'base'

class INatGet::Condition::Q

  include INatGet::Condition::Base

  attr_reader :query

  def initialize helper, **query
    @helper
    @query = query
  end

  def helper
    @helper
  end

  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(Q)
    self.query == other.query && self.helper == other.helper
  end

  class Maker
    def initialize helper
      @helper = helper
    end

    def [] **query
      return ANYTHING if query.empty?
      INatGet::Condition::Q[@helper, **query]
    end
  end

  class << self

    private def maker helper
      @makers ||= {}
      @makers[helper] ||= Maker::new(helper)
    end

    def [] helper, **query
      return maker(helper) if query.empty?
      new(helper, **query).freeze
    end

    private :new

  end

  def merge_n_factor
    Q[@helper][ **prepare_query(**@query) ]
  end

  private 

  def prepare_query **query
    # TODO: Enumerable => Set, scalar => Set[ scalar ], Symbol => Enum(?), Set<Symbol>, Range<Symbol> => Set<Enum>, Range<Enum>
    #       подумать, как ввести енумы без передачи имени поля (ввести таблицу enum-полей?) Также подумать, как превращать даты в Range.
    #       А возможно, добавить хелпер с учетом класса.
    # TODO: логика таксонов [ ancestor_id, descendant_id ] => [ ancestor_id ]
    # TODO: Парсинг проектов
  end

end

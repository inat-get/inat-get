# frozen_string_literal: true

require_relative '../../info'

module INatGet::Data; end

# @api private
class INatGet::Data::Helper

  # @return [Hash]
  def prepare_query **query
    # TODO: implement
    # Вызывается в процессе нормализации условий — ДО преобразований для API и Sequel
    # Выполняем слеюущие преобразования
    #   - Date и диапазоны Date — в диапазоны Time
    #   - Одиночные значения там, где допустим перечень — в Set
    #   - Диапазоны Rank — в Set<Rank>
    #   - Широта, долгота и Location — в диапазоны широты и долготы
    #   - Символы в строки
    # Модели в примитивы на этом этапе НЕ преобразуем, тем более не преобразуем данные между полями.
    raise NotImplementedError, "Not implemented method 'prepare_query' in abstract class", caller_locations
  end

  # Raises exception if any field is not valid.
  # @return [Boolean]
  def validate_query(**query) = raise NotImplementedError, "Not implemented method 'validate_query' in abstract class", caller_locations

  # @return [Hash]
  def query_to_api(**query) = raise NotImplementedError, "Not implemented method 'query_to_api' in abstract class", caller_locations

  # @return [Sequel::SQL::Expression]
  def query_to_sequel(**query) = raise NotImplementedError, "Not implemented method 'query_to_sequel' in abstract class", caller_locations

end

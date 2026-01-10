# frozen_string_literal: true

require_relative '../info'

module INatGet::Utils; end

module INatGet::Utils::Enums

  class << self

    def make_enum enum, value
      raise ArgumentError, "Invalid enum type: #{ enum.inspect }", caller_locations unless enum.is_a?(Class) && enum < IS::Enum
      case value
      when nil
        nil
      when enum
        value
      when Symbol
        enum.of value
      when Range
        Range::new make_enum(enum, value.begin), make_enum(enum, value.end), value.exclude_end?
      when Enumerable
        Set[ *value.map { |v| make_enum(enum, v) } ]
      else
        raise ArgumentError, "Invalid value for #{ enum }: #{ value.inspect }", caller_locations
      end
    end

  end

end

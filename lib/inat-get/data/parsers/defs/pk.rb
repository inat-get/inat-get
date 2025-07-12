# frozen_string_literal: true

require 'set'

require_relative '../defs'

class INatGet::Data::Parser::Part::PK < INatGet::Data::Parser::Part

  def initialize parser, **aliases
    super parser
    @aliases = aliases
    @registered = Set::new
  end

  def parse source
    @pk_cols ||= Array(parser.model.primary_key)
    result = {}
    @pk_cols.each do |col|
      src_col = @aliases[col] || col
      result[col] = source[src_col]
    end
    key = result.values_at(*@pk_cols)
    if @registered.include?(key)
      result[:_registered] = key
    end
    @registered << key
    result
  end

end

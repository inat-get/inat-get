# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Parser::Part::PK < INatGet::Data::Parser::Part

  def initialize parser, **aliases
    super parser
    @pk_cols = parser.model.primary_key
    @aliases = aliases
  end

  def parse source
    result = {}
    @pk_cols.each do |col|
      src_col = @aliases[col] || col
      result[col] = source[src_col]
    end
    result
  end

end

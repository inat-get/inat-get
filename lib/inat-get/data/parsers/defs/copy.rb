# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Parser::Part::Copy < INatGet::Data::Parser::Part

  def initialize parser, *names, **aliases
    super parser
    @names = names
    @aliases = aliases
  end

  def parse source
    result = {}
    @names.each do |name|
      result[name] = source[name]
    end
    @aliases.each do |name, src_name|
      result[name] = source[src_name]
    end
    result
  end

end


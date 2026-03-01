# frozen_string_literal: true

require_relative 'copy'

class INatGet::Data::Parser::Part::Time < INatGet::Data::Parser::Part::Copy

  def parse source
    result = {}
    @names.each do |name|
      value = source[name]
      result[name] = ::Time.parse value if value
    end
    @aliases.each do |name, src_name|
      value = source[src_name]
      result[name] = ::Time.parse value if value
    end
    result
  end

end

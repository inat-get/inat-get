# frozen_string_literal: true

require 'json'

require_relative 'copy'

class INatGet::Data::Parser::Part::JSON < INatGet::Data::Parser::Part::Copy

  def parse source
    result = {}
    @names.each do |name|
      result[name] = source[name].to_json
    end
    @aliases.each do |name, src_name|
      result[name] = source[src_name].to_json
    end
    result
  end

end

# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Parser::Part::Cached < INatGet::Data::Parser::Part

  def parse source
    { cached: ::Time::now }
  end

end

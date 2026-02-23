# frozen_string_literal: true

class INatGet::Data::Parser::Part::PrjType < INatGet::Data::Parser::Part

  def parse source
    result = {}
    result[:project_type]  = source[:project_type]
    result[:is_umbrella]   = source[:is_umbrella]
    result[:is_collection] = result[:project_type] == 'collection'
    result
  end

end

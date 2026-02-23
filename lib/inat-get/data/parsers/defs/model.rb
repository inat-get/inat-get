# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Parser::Part::Model < INatGet::Data::Parser::Part

  def initialize parser, name, model:, source: nil, source_id: nil
    super parser
    @name = name
    @model = model
    @source = source || @name
    @source_id = source_id || "#{ @source }_id".to_sym
  end

  def parse source
    data = source[@source]
    if data
      { @name => @model.parser.entry!(data) }
    else
      id = source[@source_id]
      if id
        { @name => Array(@model.manager.get(id)).first }
      else
        { @name => nil }
      end
    end
  end

end

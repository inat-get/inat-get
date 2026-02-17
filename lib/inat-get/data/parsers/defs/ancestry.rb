# frozen_string_literal: true

require_relative 'links'

class INatGet::Data::Parser::Part::Ancestry < INatGet::Data::Parser::Part::Links

  def initialize parser, name, source: nil, source_ids: nil
    super parser, model: parser.model, source: source, source_ids: source_ids
  end

  def parse target, source
    data = source[@source]
    values = if data
      @model.parser.parse! data
    else
      ids = source[@source_ids] || []
      @model.manager.get ids
    end
    ids = values.map(&:id)
    ids << target.id unless ids.include?(target.id)
    field = @parser.model.association_reflection(@name)[:pks_setter_method].to_s.chomp("=").to_sym
    { field => ids }
  end

end

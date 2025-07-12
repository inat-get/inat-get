# frozen_string_literal: true

class INatGet::Data::Parser::Part::Links < INatGet::Data::Parser::Part::Assoc

  def parse target, source
    data = source[@source]
    values = if data
      @model.parser.parse! data
    else
      ids = source[@source_ids] || []
      @model.manager.get(*ids)
    end
    ids = Array(values).map(&:id)
    field = @parser.model.association_reflection(@name)[:pks_setter_method].to_s.chomp('=').gsub('_setter', '').to_sym
    { field => ids }
  end

end

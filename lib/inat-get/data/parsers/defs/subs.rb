# frozen_string_literal: true

class INatGet::Data::Parser::Part::Children < INatGet::Data::Parser::Part::Assoc

  # @return [nil]
  def parse target, source
    data = source[@source] || []
    values = @model.parser.parse!(data.map { |r| r.merge(owner_id: target.id) })
    existing = target.send(@name)
    existing.reject { |r| values.include?(r) }.each(&:delete) if existing
    nil
  end

end

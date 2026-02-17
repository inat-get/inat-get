# frozen_string_literal: true

class INatGet::Data::Parser::Part::Children < INatGet::Data::Parser::Part::Assoc

  # @return [nil]
  def parse target, source
    data = source[@source] || []
    values = @model.parser.parse!(data.map { |r| r.is_a?(Hash) ? r.merge(owner_id: target.id) : { owner_id: target.id, value: r } })
    existing = target.send(@name)
    existing.reject { |r| values.include?(r) }.each(&:delete) if existing
    nil
  end

end

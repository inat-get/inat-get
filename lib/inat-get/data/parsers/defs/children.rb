# frozen_string_literal: true

class INatGet::Data::Parser::Part::Children < INatGet::Data::Parser::Part::Assoc

  # @return [nil]
  def parse target, source
    data = source[@source] || []
    values = @model.parser.parse!(data.map { |r| r.is_a?(Hash) ? r.merge(owner_id: target.id) : { owner_id: target.id, value: r } })
    pks = values.map { |v| v.primary_key }
    existing = target.send(@name)
    existing.reject { |r| pks.include?(r.primary_key) }.each(&:delete) if existing
    nil
  end

end

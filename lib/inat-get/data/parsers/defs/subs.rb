# frozen_string_literal: true

class INatGet::Data::Parser::Part::Subs < INatGet::Data::Parser::Part

  def apply target, source
    parser = @args.first
    args = @args[1..]
    args.each do |arg|
      value = source[arg] || []
      # new_ids = value.map { |v| v[:id] }
      # existing = target[arg]
      # existing.reject { |r| new_ids.include?(r.id) }.delete if existing
      value.each { |v| v[:owner_id] = target.id }
      value = parser.parse! value
    end
    @kwargs.each do |s_key, t_key|
      value = source[s_key] || []
      # new_ids = value.map { |v| v[:id] }
      # existing = target[t_key]
      # existing.reject { |r| new_ids.include?(r.id) }.delete if existing
      value.each { |v| v[:owner_id] = target.id }
      value = parser.parse! value
    end
  end

end

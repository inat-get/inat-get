# frozen_string_literal: true

require_relative 'scalar'

class INatGet::Data::Parser::Part::Time < INatGet::Data::Parser::Part

  def apply target, source
    fields = {}
    @args.each do |arg|
      value = source[arg]
      value = Time.parse value if value
      fields[arg] = value
    end
    @kwargs.each do |s_key, t_key|
      value = source[s_key]
      value = Time.parse value if value
      fields[t_key] = value
    end
    target.set(**fields)
  end

end

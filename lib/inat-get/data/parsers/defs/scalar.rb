# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Parser::Part::Scalar < INatGet::Data::Parser::Part

  def apply target, source
    fields = {}
    @args.each do |arg|
      fields[arg] = source[arg]
    end
    @kwargs.each do |key, value|
      fields[value] = source[key]
    end
    target.set(**fields)
  end

end


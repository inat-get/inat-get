# frozen_string_literal: true

class INatGet::Data::Parser::Part::StrLocation < INatGet::Data::Parser::Part

  def initialize parser, source = :location
    super parser
    @source = source
  end

  def parse source
    value = source[@source]
    if value && value.is_a?(String) && !value.empty?
      values = value.split(',').map(&:to_f)
      {
        latitude: values[0],
        longitude: values[1]
      }
    else
      {}
    end
  end

end

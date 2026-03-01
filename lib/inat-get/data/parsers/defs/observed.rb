# frozen_string_literal: true

require_relative 'time'

class INatGet::Data::Parser::Part::Observed < INatGet::Data::Parser::Part::Time

  def initialize parser
    super parser, observed: :time_observed_at
  end

  def parse value
    result = super value
    result[:observed] ||= ::Time::parse value[:observed_on]
    result
  end

end

# frozen_string_literal: true

require 'json'
require 'set'
require 'time'
require 'date'

class Time

  def to_json(*)
    "\"#{ xmlschema(9) }\""
  end

end

class Date

  def to_json(*)
    "\"#{ xmlschema }\""
  end

end

class Set

  def to_json(*)
    to_a.to_json
  end

end

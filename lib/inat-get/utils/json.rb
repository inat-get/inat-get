# frozen_string_literal: true

require 'json'
require 'set'
require 'time'
require 'date'

# @private
class Time

  # @return [String]
  def to_json(*)
    "\"#{ xmlschema(9) }\""
  end

end

# # @private
# class DateTime

#   # @return [String]
#   def to_json(*)
#     "\"#{ xmlschema(9) }\""
#   end

# end

# @private
class Date

  # @return [String]
  def to_json(*)
    "\"#{ xmlschema }\""
  end

end

# @private
class Set

  # @return [String]
  def to_json(*)
    to_a.to_json
  end

end

# frozen_string_literal: true

require_relative '../../info'

# @api private
class INatGet::Data::Parser

  def parse! src
    case src
    when Enumerable
      src.map { |s| entry!(s) }
    else
      entry! src
    end
  end

  # @return [Model]
  def entry!(data) = raise NorImplementedError, "Not implemented method 'entry!' of abstract class", caller_locations

  # @return [Model]
  def fake(data) = raise NorImplementedError, "Not implemented method 'fake' of abstract class", caller_locations

end

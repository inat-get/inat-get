# frozen_string_literal: true

require 'set'

require_relative '../../info'

module INatGet::Data; end
module INatGet::Data::Helper; end

# @api private
class INatGet::Data::Helper::Field

  # @return [Boolean]
  def === value
    raise NotImplementedError, "Not implemented method '===' for abstract class", caller_locations
  end

  # @return [Hash, Object]
  def << value
    raise NotImplementedError, "Not implemented method '<<' for abstract class", caller_locations
  end

end

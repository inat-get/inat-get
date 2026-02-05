# frozen_string_literal: true

require 'singleton'

require_relative '../../info'

module INatGet::Data; end

module INatGet::Data::Manager; end

class INatGet::Data::Manager::Base

  # @return [Symbol]
  def entrypoint = raise NorImplementedError, "Not implemented 'entrypoint' in abstract base class", caller_locations

  # @return [class of Sequel::Model]
  def model = raise NorImplementedError, "Not implemented 'model' is abstract base class", caller_locations

end

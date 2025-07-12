# frozen_string_literals: true

require_relative '../../utils/utils'
require_relative '../../core'
require_relative '../cached'
require_relative '../types'

class INatGet::Model < INatGet::Cached

  class << self

    # @!group Metadata Configuration

    def endpoint value = nil
      case value
      when String
        @endpoint = value.intern
      when Symbol, false
        @endpoint = value
      when nil
        # nothing to do
      else
        raise ArgumentError, "Invalid 'endpoint' attribute: #{ value.inspect }", caller
      end
      @endpoint
    end

    # @!endgroup

    def fetch *cache_keys
      # TODO: implement
    end

  end

end

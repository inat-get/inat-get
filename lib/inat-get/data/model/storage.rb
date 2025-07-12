# frozen_string_literals: true

require 'set'

require_relative '../../utils/utils'
require_relative '../../core'
require_relative '../cached'
require_relative '../types'

class INatGet::Model < INatGet::Cached

  class << self

    # @!group Metadata Configuration

    def table value = nil
      @@tables ||= Set::new
      case value
      when String
        @@tables.delete @table if @table
        @table = value.intern
        @@tables << @table
      when Symbol, false
        @@tables.delete @table if @table
        @table = value
        @@tables << @table if @table
      when nil
        # nothing to do
      else
        raise ArgumentError, "Invalid 'table' attribute: #{ value.inspect }", caller
      end
      @table
    end

    #@!endgroup

    # @!group Global Metadata Information

    def tables
      @@tables ||= {}
      @@tables
    end

    # @!endgroup

    def load *cache_keys
      # TODO: implement
    end

  end

end

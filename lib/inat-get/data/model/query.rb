# frozen_string_literals: true

require_relative '../../utils/utils'
require_relative '../../core'
require_relative '../cached'
require_relative '../types'

class INatGet::Model < INatGet::Cached

  class << self

    # @!group Querying Definition

    # @overload query_parameter(*names, no_range: false, no_array: false)
    # @overload query_parameter(name, &block)
    def query_parameter *names, no_array: false, &block
      # TODO: implement
    end

    # @overload where_parameter(*names, no_range: false, no_array: false)
    # @overload where_parameter(name, &block)
    def where_parameter *names, no_range: false, no_array: false, &block
      # TODO: implement
    end

    # @!endgroup

    # @!group Querying Information

    def query_parameters
      # TODO: implement
    end

    def where_parameters
      # TODO: implement
    end

    # @!endgroup

    # @!group Querying Execution

    def select *keys, **params, &block
      # TODO: implement
    end

    # @!endgroup

  end

end

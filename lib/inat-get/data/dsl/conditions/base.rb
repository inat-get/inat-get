# frozen_string_literal

require 'singleton'
require 'is-range'

require_relative '../../../info'

module INatGet::Data; end
module INatGet::Data::DSL; end

class INatGet::Data::DSL::Condition

  include INatGet::Data::DSL

  # @group Metadata

  # @api private
  # @!attribute [ro] manager
  # @return [INatGet::Data::Manager]
  def manager = self.model.manager

  # @api private
  # @!attribute [ro] model
  # @return [class of Sequel::Model]
  def model = raise NotImplementedError, "Not implemented method 'model' for abstract class.", caller_locations

  # @endgroup

  # @group Operators

  # @return [Condition]
  def & other
    return self if other == ANYTHING
    return NOTHING if other == NOTHING
    AND[ self, other ]
  end

  # @return [Condition]
  def | other
    return self if other == NOTHING
    return ANYTHING if other == ANYTHING
    OR[ self, other ]
  end

  # @return [Condition]
  def !
    NOT[ self ]
  end

  # @endgroup

  # @group Transformation

  protected

  # @private
  # @return [Condition]
  def normalize
    self.expand_references.flatten.push_not_down.flatten.push_and_down.flatten.merge_n_factor.flatten
  end

  # @private
  def flatten
    self
  end

  # @private
  def push_not_down
    self
  end

  # @private
  def push_and_down
    self
  end

  # @private
  def merge_n_factor
    self
  end

  # @private
  def simplify
    self
  end

  # @private
  def expand_references
    self
  end

  # @private
  def to_api
    raise TypeError, "Invalid condition type for API query", caller_locations
  end

  # @private
  def to_sequel
    raise TypeError, "Invalid condition type for DB query", caller_locations
  end

  public

  # @api private
  # @return [Array<Hash>]
  def api_query
    normalize.simplify.send :to_api
  end

  # @api private
  # @return [Sequel::SQL::Expression]
  def sequel_query
    normalize.send :to_sequel
  end

  # @endgroup

end

class INatGet::Data::DSL::Condition::Nothing < INatGet::Data::DSL::Condition

  include Singleton

  # @group Operators

  # @return [Condition]
  def & other
    self
  end

  # @return [Condition]
  def | other
    other
  end

  # @return [Condition]
  def !
    ANYTHING
  end

  # @endgroup

  # @private
  def to_api
    []
  end

  # @private
  def to_sequel
    Sequel.lit 'false'
  end

end

class INatGet::Data::DSL::Condition::Anything < INatGet::Data::DSL::Condition

  include Singleton

  # @group Operators

  # @return [Condition]
  def & other
    other
  end

  # @return [Condition]
  def | other
    self
  end

  # @return [Condition]
  def !
    NOTHING
  end

  # @endgroup

  # @private
  def to_sequel
    Sequel.lit 'true'
  end

end

module INatGet::Data::DSL

  # @group Conditions

  # @!method NOTHING
  #   @return [Condition::Nothing]
  # @private
  NOTHING = Condition::Nothing::instance.freeze
  
  # @!method ANYTHING
  #   @return [Condition::Anything]
  # @private
  ANYTHING = Condition::Anything::instance.freeze

  # @endgroup

end



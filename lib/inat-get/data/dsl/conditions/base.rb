# frozen_string_literal

require 'singleton'

require_relative '../../../info'
require_relative '../../../utils/ranges'

module INatGet::Data; end
module INatGet::Data::DSL; end
module INatGet::Data::DSL::Condition; end

class INatGet::Data::DSL::Condition::Base

  include INatGet::Data::DSL::Condition

  def helper
    nil
  end

  def & other
    AND[ self, other ]
  end

  def | other
    OR[ self, other ]
  end

  def !
    NOT[ self ]
  end

  def normalize
    self.flatten.push_not_down.flatten.push_and_down.flatten.merge_n_factor.flatten
  end

  def flatten
    self
  end

  def push_not_down
    self
  end

  def push_and_down
    self
  end

  def merge_n_factor
    self
  end

  def simplify
    self
  end

  def api_query
    normalize.simplify.to_api
  end

  def sequel_query
    normalize.to_sequel
  end

  def to_api
    raise TypeError, "Invalid condition type for API query", caller_locations
  end

  def to_sequel
    raise TypeError, "Invalid condition type for DB query", caller_locations
  end

end

class INatGet::Data::DSL::Condition::Nothing < INatGet::Data::DSL::Condition::Base

  include Singleton

  def & other
    self
  end

  def | other
    other
  end

  def !
    ANYTHING
  end

  def to_api
    []
  end

  def to_sequel
    Sequel.lit 'false'
  end

end

class INatGet::Data::DSL::Condition::Anything < INatGet::Data::DSL::Condition::Base

  include Singleton

  def & other
    other
  end

  def | other
    self
  end

  def !
    NOTHING
  end

  def to_sequel
    Sequel.lit 'true'
  end

end

module INatGet::Data::DSL::Condition

  NOTHING = Nothing::instance.freeze
  ANYTHING = Anything::instance.freeze

end

# frozen_string_literal

require 'singleton'

require_relative '../info'

module INatGet::Condition; end

module INatGet::Condition::Base

  include INatGet::Condition

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

end

class INatGet::Condition::Nothing

  include Singleton
  include INatGet::Condition::Base

  def & other
    self
  end

  def | other
    other
  end

  def !
    ANYTHING
  end

end

class INatGet::Condition::Anything

  include Singleton
  include INatGet::Condition::Base

  def & other
    other
  end

  def | other
    self
  end

  def !
    NOTHING
  end

end

module INatGet::Condition

  NOTHING = Nothing::instance.freeze
  ANYTHING = Anything::instance.freeze

end

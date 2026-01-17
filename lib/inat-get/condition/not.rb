# frozen_string_literal: true

require_relative 'base'

class INatGet::Condition::NOT

  include INatGet::Condition::Base

  attr_reader :operand

  def initialize operand
    @operand = operand
  end

  def helper
    @operand.helper
  end

  def & other
    if @operand == other
      NOTHING
    else
      AND[ self, other ]
    end
  end

  def | other
    if @operand == other
      ANYTHING
    else
      OR[ self, other ]
    end
  end

  def !
    @operand
  end

  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(NOT)
    self.operand == other.operand
  end

  class << self

    def [] operand
      case operand
      when Nothing
        ANYTHING
      when Anything
        NOTHING
      when NOT
        operand.operand
      else
        new(operand).freeze
      end
    end

    private :new

  end

  def flatten
    if @operand.is_a?(NOT)
      @operand.operand.flatten
    else
      NOT[ @operand.flatten ]
    end
  end

  def push_not_down
    case @operand
    when AND
      OR[ @operand.operands.map { |o| NOT[ o.push_not_down ] } ]
    when OR
      AND[ @operand.operands.map { |o| NOT[ o.push_not_down ] } ]
    when NOT
      @operand.operand.push_not_down
    else
      self
    end
  end

  def merge_n_factor
    NOT[ @operand.merge_n_factor ]
  end

  def simplify
    ANYTHING
  end

  def to_sequel
    Sequel.~(@operand.to_sequel)
  end

end

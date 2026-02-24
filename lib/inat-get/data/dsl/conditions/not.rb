# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::DSL::Condition::NOT < INatGet::Data::DSL::Condition

  # @group Metadata

  # @api private
  # @return [Condition]
  attr_reader :operand

  # @api private
  # @!attribute [ro] model
  # @return [class of Sequel::Model]
  def model
    @operand.model
  end

  # @endgroup

  # @private
  def initialize operand
    @operand = operand
  end

  # @group Operators

  # @return [Condition]
  def & other
    if @operand == other
      INatGet::Data::DSL::NOTHING
    else
      AND[ self, other ]
    end
  end

  # @return [Condition]
  def | other
    if @operand == other
      INatGet::Data::DSL::ANYTHING
    else
      OR[ self, other ]
    end
  end

  # @return [Condition]
  def !
    @operand
  end

  # @return [Boolean]
  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(NOT)
    self.operand == other.operand
  end

  # @endgroup

  class << self

    # @group Constructor

    # @return [Condition]
    def [] operand
      case operand
      when INatGet::Data::DSL::Condition::Nothing
        INatGet::Data::DSL::ANYTHING
      when INatGet::Data::DSL::Condition::Anything
        INatGet::Data::DSL::NOTHING
      when INatGet::Data::DSL::Condition::NOT
        operand.operand
      else
        new(operand).freeze
      end
    end

    # @endgroup

    private :new

  end

  protected

  # @private
  def flatten
    if @operand.is_a?(NOT)
      @operand.operand.flatten
    else
      NOT[ @operand.flatten ]
    end
  end

  # @private
  def expand_references
    NOT[ @operand.send :expand_references ]
  end

  # @private
  def push_not_down
    case @operand
    when AND
      OR[ *@operand.operands.map { |o| NOT[ o.push_not_down ] } ]
    when OR
      AND[ *@operand.operands.map { |o| NOT[ o.push_not_down ] } ]
    when NOT
      @operand.operand.push_not_down
    else
      self
    end
  end

  # @private
  def merge_n_factor
    NOT[ @operand.send :merge_n_factor ]
  end

  # @private
  def simplify
    INatGet::Data::DSL::ANYTHING
  end

  # @private
  def to_sequel
    Sequel.~(@operand.send :to_sequel)
  end

end

module INatGet::Data::DSL

  # @group Conditions

  # @param [Condition] operand
  # @return [Condition::NOT]
  def NOT(operand) = Condition::NOT[operand]

  # @endgroup

end

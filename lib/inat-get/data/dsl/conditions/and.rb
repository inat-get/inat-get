# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::DSL::Condition::AND < INatGet::Data::DSL::Condition

  # @group Metadata

  # @api private
  # @return [Array<Condition>]
  attr_reader :operands

  # @private
  def initialize *operands
    @operands = operands
  end

  # @api private
  # @!attribute [ro] model
  # @return [class of Sequel::Model]
  def model
    @operands.map(&:model).find { |h| !h.nil? }
  end

  # @endgroup

  # @group Operators

  # @return [Condition]
  def & other
    if other.is_a?(AND)
      AND[ *self.operands, *other.operands ]
    else
      AND[ *self.operands, other ]
    end
  end

  # @return [Boolean]
  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(AND)
    self.operands.all? { |o| other.operands.include?(o) } && other.operands.all? { |o| self.operands.include?(o) }
  end

  # @endgroup

  class << self

    # @group Constructor

    # @return [Condition]
    def [] *operands
      return INatGet::Data::DSL::ANYTHING if operands.empty?
      return INatGet::Data::DSL::NOTHING if operands.include?(INatGet::Data::DSL::NOTHING)
      operands.delete INatGet::Data::DSL::ANYTHING
      new(*operands).freeze
    end

    # @endgroup

    private :new

  end

  # @private
  def flatten
    and_operands, other_operands = @operands.map(&:flatten).partition { |o| o.is_a?(AND) }
    flatten_operands = and_operands.map(&:operands).flatten
    AND[ *flatten_operands, *other_operands ]
  end

  # @private
  def expand_references
    AND[ *@operands.map(&:expand_references) ]
  end

  # @private
  def push_not_down
    AND[ *@operands.map(&:push_not_down) ]
  end

  # @private
  def push_and_down
    ops = @operands.dup
    or_index = ops.index { |o| o.is_a?(OR) }
    if or_index
      or_operand = ops.delete_at or_index
      OR[ *or_operand.operands.map { |o| AND[ o, *ops ].push_and_down } ]
    else
      AND[ *@operands.map(&:push_and_down) ]
    end
  end

  # @private
  def merge_n_factor
    query_operands, rest = @operands.map(&:merge_n_factor).partition { |o| o.is_a?(Query) }
    not_operands, other_operands = rest.partition { |o| o.is_a?(NOT) }
    return NOTHING if not_operands.any? { |o| query_operands.include?(o.operand) || other_operands.include?(o.operand) }
    query_op = and_merge(*query_operands).merge_n_factor
    not_op = NOT[ OR[ *not_operands.map(&:operand) ].merge_n_factor ]
    AND[ query_op, not_op, *other_operands ]
  end

  # @private
  def simplify
    AND[ *@operands.map(&:simplify) ].normalize
  end

  # @private
  def to_sequel
    Sequel.&(@operands.map(&:to_sequel))
  end

  private

  # @private
  def and_merge *queries
    # TODO: внедрить логику таксонов: ancesor_id & descendant_id => descendant_id
    # cur_helper = self.model.helper
    query = {}
    queries.map(&:query).each do |q|
      q.compact!
      q.each do |key, value|
        if query.has_key?(key)
          val = query[key]
          unless val == value
            case val
            when true, false
              return NOTHING
            when Set
              if value.is_a?(Set)
                query[key] = val & value
              elsif value.is_a?(Range)
                query[key] = val.keep_if { |v| value.include?(v) }
              else
                return NOTHING
              end
            when Range
              if value.is_a?(Range)
                query[key] = val & value
              elsif value.is_a?(Set)
                query[key] = value.keep_if { |v| val.include?(v) }
              else
                return NOTHING
              end
            else
              return NOTHING
            end
            return NOTHING if query[key].nil? || query[key].empty?
          end
        else
          query[key] = value
        end
      end
      query.compact!
    end
    Query[self.model][ **query ]
  end

end

module INatGet::Data::DSL

  # @group Conditions

  # @param [Array<Condition>] operands
  # @return [Condition::AND]
  def AND(*operands) = Condition::AND[*operands]

  # @endgroup

end

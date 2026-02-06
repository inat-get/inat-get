# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::DSL::Condition::AND < INatGet::Data::DSL::Condition::Base

  attr_reader :operands

  def initialize *operands
    @operands = operands
  end

  def helper
    @operands.map(&:helper).find { |h| !h.nil? }
  end

  def & other
    if other.is_a?(AND)
      AND[ *self.operands, *other.operands ]
    else
      AND[ *self.operands, other ]
    end
  end

  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(AND)
    self.operands.all? { |o| other.operands.include?(o) } && other.operands.all? { |o| self.operands.include?(o) }
  end

  class << self

    def [] *operands
      return ANYTHING if operands.empty?
      return NOTHING if operands.include?(NOTHING)
      operands.delete ANYTHING
      new(*operands).freeze
    end

    private :new

  end

  def flatten
    and_operands, other_operands = @operands.map(&:flatten).partition { |o| o.is_a?(AND) }
    flatten_operands = and_operands.map(&:operands).flatten
    AND[ *flatten_operands, *other_operands ]
  end

  def push_not_down
    AND[ *@operands.map { |o| o.push_not_down } ]
  end

  def push_and_down
    ops = @operands.dup
    or_index = ops.index { |o| o.is_a?(OR) }
    if or_index
      or_operand = ops.delete_at or_index
      OR[ *or_operand.operands.map { |o| AND[ o, *ops ].push_and_down } ]
    else
      AND[ *@operands.map { |o| o.push_and_down } ]
    end
  end

  def merge_n_factor
    query_operands, rest = @operands.map(&:merge_n_factor).partition { |o| o.is_a?(Q) }
    not_operands, other_operands = rest.partition { |o| o.is_a?(NOT) }
    return NOTHING if not_operands.any? { |o| query_operands.include?(o.operand) || other_operands.include?(o.operand) }
    query_op = and_merge(*query_operands).merge_n_factor
    not_op = NOT[ OR[ *not_operands.map(&:operand) ].merge_n_factor ]
    AND[ query_op, not_op, *other_operands ]
  end

  def simplify
    AND[ *@operands.map(&:simplify) ].normalize
  end

  def to_sequel
    Sequel.&(@operands.map(&:to_sequel))
  end

  private

  def and_merge *queries
    # TODO: внедрить логику таксонов: ancesor_id & descendant_id => descendant_id
    cur_helper = self.helper
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
    Q[cur_helper][ **query ]
  end

end

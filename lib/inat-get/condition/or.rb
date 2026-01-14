# frozen_string_literal: true

require_relative 'base'

class INatGet::Condition::OR

  include INatGet::Condition::Base

  attr_reader :operands

  def initialize *operands
    @operands = operands
  end

  def helper
    @operands.map(&:helper).find { |h| !h.nil? }
  end

  def | other
    if other.is_a?(OR)
      OR[ *self.operands, *other.operands ]
    else
      OR[ *self.operands, other ]
    end
  end

  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(OR)
    self.operands.all? { |o| other.operands.include?(o) } && other.operands.all? { |o| self.operands.include?(o) }
  end

  class << self

    def [] *operands
      return NOTHING if operands.empty?
      return ANYTHING if operands.include?(ANYTHING)
      operands.delete NOTHING
      new(*operands).freeze
    end

    private :new

  end

  def flatten
    or_operands, other_operands = @operands.map(&:flatten).partition { |o| o.is_a?(OR) }
    flatten_operands = or_operands.map(&:operands).flatten
    OR[ *flatten_operands, *other_operands ]
  end

  def push_not_down
    OR[ *@operands.map { |o| o.push_not_down } ]
  end

  def push_and_down
    OR[ *@operands.map { |o| o.push_and_down } ]
  end

  def merge_n_factor
    query_operands, other_operands = @operands.map(&:merge_n_factor).partition { |o| o.is_a?(Q) }
    not_operands = other_operands.select { |o| o.is_a?(NOT) }
    return ANYTHING if not_operands.any? { |o| query_operands.include?(o.operand) || other_operands.include?(o.operand) }
    query_ops = or_merge(*query_operands)
    OR[ *query_ops, *other_operands ]
  end

  private

  def or_merge *queries
    queries = queries.compact
    return queries if queries.size <= 1
    changes_flag = false
    (0 .. queries.size - 1).each do |index|
      current = queries[index]
      queries[index] = nil
      (0 .. queries.size - 1).each do |idx|
        second = queries[idx]
        next if second.nil?
        if hash_cover?(current.query, second.query)
          queries[idx] = nil
          changes_flag = true
          next
        elsif hash_cover?(second.query, current.query)
          current = nil
          changes_flag = true
          break
        else
          trying = hash_try_merge current.query, second.query
          if trying
            cur_helper = current.helper
            current = Q[cur_helper][ **trying ]
            queries[idx] = nil
            changes_flag = true
            next
          end
        end
      end
      queries[index] = current
    end
    queries = or_merge(*queries) if changes_flag
    queries.compact
  end

  def hash_cover? first, second
    # TODO: логика таксонов ancestor_id >= descendant_id
    first.each do |key, value|
      if second.has_key?(key)
        val = second[key]
        case value
        when Set
          return false unless value >= val
        when Range
          return false unless value.cover?(val)
        else
          return false unless value == val
        end
      else
        return false
      end
    end
    true
  end

  def hash_try_merge first, second
    # TODO: логика таксонов
    first = first.dup.compact
    second = second.dup.compact
    result = {}
    merged = false
    first.each do |key, value|
      if second.has_key?(key)
        val = second.delete key
        if val == value
          result[key] = value
        else
          case value
          when true, false
            return false if merged
            result[key] = nil
            merged = true
          when Set
            if val.is_a?(Set)
              return false if merged
              result[key] = value | val
              merged = true
            elsif !val.is_a?(Range)
              return false if merged
              result[key] = value
              result[key] << val
              merged = true
            else
              return false
            end
          when Range
            if val.is_a?(Range)
              return false if merged
              result[key] = value | val
              return false if result[key] == nil
              merged = true
            elsif value.cover?(val)
              return false if merged
              result[key] = value | val
              merged = true
            else
              return false
            end
          else
            case val
            when Set
              return false if merged
              result[key] = val
              result[key] << value
              merged = true
            when Range
              if val.cover?(value)
                return false if merged
                result[key] = val
                merged = true
              else
                return false
              end
            else
              return false if merged
              result[key] = Set[ value, val ]
              merged = true
            end
          end
        end
      else
        return false if merged
        # result[key] = nil       # merged state nil | some = nil, unnecessary assignment
        merged = true
      end
    end
    return false if merged && !second.empty?
    result.compact!
  end

end

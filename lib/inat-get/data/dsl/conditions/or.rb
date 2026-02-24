# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::DSL::Condition::OR < INatGet::Data::DSL::Condition

  # @group Metadata

  # @api private
  # @return [Array<Condition>]
  attr_reader :operands

  # @api private
  # @!attribute [ro] model
  # @return [class of Sequel::Model]
  def model
    @operands.map(&:model).find { |h| !h.nil? }
  end

  # @endgroup

  # @private
  def initialize *operands
    @operands = operands
  end

  # @group Operators

  # @return [Condition]
  def | other
    if other.is_a?(OR)
      OR[ *self.operands, *other.operands ]
    else
      OR[ *self.operands, other ]
    end
  end

  # @return [Boolean]
  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(OR)
    self.operands.all? { |o| other.operands.include?(o) } && other.operands.all? { |o| self.operands.include?(o) }
  end

  # @endgroup

  class << self

    # @group Constructor

    # @return [Condition]
    def [] *operands
      return INatGet::Data::DSL::NOTHING if operands.empty?
      return INatGet::Data::DSL::ANYTHING if operands.include?(INatGet::Data::DSL::ANYTHING)
      operands.delete INatGet::Data::DSL::NOTHING
      return operands.first if operands.size == 1
      new(*operands).freeze
    end

    # @endgroup

    private :new

  end

  protected

  # @private
  def flatten
    or_operands, other_operands = @operands.map { it.send :flatten }.partition { |o| o.is_a?(OR) }
    flatten_operands = or_operands.map(&:operands).flatten
    OR[ *flatten_operands, *other_operands ]
  end

  # @private
  def expand_references
    OR[ *@operands.map { it.send :expand_references } ]
  end

  # @private
  def push_not_down
    OR[ *@operands.map { it.send :push_not_down } ]
  end

  # @private
  def push_and_down
    OR[ *@operands.map { it.send :push_and_down } ]
  end

  # @private
  def merge_n_factor
    query_operands, other_operands = @operands.map { it.send :merge_n_factor }.partition { |o| o.is_a?(Query) }
    not_operands = other_operands.select { |o| o.is_a?(NOT) }
    return ANYTHING if not_operands.any? { |o| query_operands.include?(o.operand) || other_operands.include?(o.operand) }
    query_ops = or_merge(*query_operands.map { it.send :merge_n_factor }).map { it.send :merge_n_factor }
    OR[ *query_ops, *other_operands ]
  end

  # @private
  def simplify
    OR[ *@operands.map { it.send :simplify } ].normalize
  end

  # @private
  def to_api
    @operands.map { it.send :to_api }.flatten.compact
  end

  # @private
  def to_sequel
    Sequel.|(*@operands.map(&:to_sequel))
  end

  private

  # @private
  def or_merge *queries
    queries = queries.compact
    return queries if queries.size <= 1
    changes_flag = false
    (0 .. queries.size - 1).each do |index|
      current = queries[index]
      next if current.nil?
      queries[index] = nil
      (0 .. queries.size - 1).each do |idx|
        second = queries[idx]
        next if second.nil?
        if hash_cover?(current.query, second.query)
          # pp "CURRENT >= SECOND"
          queries[idx] = nil
          changes_flag = true
          next
        elsif hash_cover?(second.query, current.query)
          # pp "CURRENT <= SECOND"
          current = nil
          changes_flag = true
          break
        else
          trying = hash_try_merge current.query, second.query
          # pp({TRYING: trying})
          if trying
            # cur_helper = current.helper
            current = Query[current.model][ **trying ]
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

  # @private
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

  # @private
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
    # pp({ RESULT: result, MERGED: merged })
    result.compact
  end

end

module INatGet::Data::DSL

  # @group Conditions

  # @param [Array<Condition>] operands
  # @return [Condition::OR]
  def OR(*operands) = Condition::OR[ *operands ]

  # @endgroup

end


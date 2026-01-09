# frozen_string_literal: true

require 'set'
require 'singleton'

require_relative '../info'
require_relative '../objects'

module INatGet::Logics; end

class INatGet::Logics::Condition; 

  def normalize
    self
  end

  def compile
    self.normalize.dive.emerge
  end

  def == other
    self.normalize.eql? other.normalize
  end

  def | other
    return self if self == other
    if other.is_a?(OrCondition)
      OrCondition::new self, *other.operands
    else
      OrCondition::new self, other
    end
  end

  def & other
    return self if self == other
    if other.is_a?(AndCondition)
      AndCondition::new self, *other.operands
    else
      AndCondition::new self, other
    end
  end

  def !
    NotCondition::new self
  end

  protected

  def dive
    self
  end

  def emerge
    self
  end

  def queries_or *queries
    # TODO: implement
  end

  def queries_and *queries
    # TODO: implement
  end

  def deep_or
    self
  end

  def deep_and
    self
  end

end

class INatGet::Logics::Nothing < INatGet::Logics::Condition

  include Singleton

  def | other
    other
  end

  def & other
    self
  end

  def !
    ANYTHING
  end

end

class INatGet::Logics::Anything < INatGet::Logics::Condition

  include Singleton

  def | other
    self
  end

  def & other
    other
  end

  def !
    NOTHING
  end

end

class INatGet::Logics::QueryCondition < INatGet::Logics::Condition

  attr_reader :query

  def initialize **query
    @query = query
  end

  def normalize
    # TODO: implement
    normalized = {}
    @query.each do |key, value|
      key = key.to_sym
      case key
      when :captive
        normalized[:captive]    = !!value unless value.nil?
      when :endemic
        normalized[:endemic]    = !!value unless value.nil?
      when :native
        normalized[:native]     = !!value unless value.nil?
      when :photos
        normalized[:photos]     = !!value unless value.nil?
      when :popular
        normalized[:popular]    = !!value unless value.nil?
      when :sounds
        normalized[:sounds]     = !!value unless value.nil?
      when :threatened
        normalized[:threatened] = !!value unless value.nil?
      when :verifiable
        normalized[:verifiable] = !!value unless value.nil?
      when :id, :observation
        case value
        when INatGet::Models::Observation
          normalized[:id] = Set[ value.id ]
        when Integer, String
          normalized[:id] = Set[ value.to_i ]
        when Enumerable
          normalized[:id] = Set[*value.map { |v| v.is_a?(INatGet::Models::Observation) ? v.id : v.to_i }]
        when nil
          # do nothing
        else
          raise ArgumentError, "Invalid value for 'id': #{ value.inspect }"
        end
      when :license
        case value
        when String, Symbol
          normalized[:license] = Set[ value.to_s.downcase ]
        when Enumerable
          normalized[:license] = Set[*value.map { |v| v.to_s.downcase }]
        when nil
          # do nothing
        else
          raise ArgumentError, "Invalid value for 'license': #{ value.inspect }"
        end
      when :photo_license
        case value
        when String, Symbol
          normalized[:photo_license] = Set[ value.to_s.downcase ]
        when Enumerable
          normalized[:photo_license] = Set[*value.map { |v| v.to_s.downcase }]
        when nil
          # do nothing
        else
          raise ArgumentError, "Invalid value for 'photo_license': #{ value.inspect }"
        end
      when :sound_license
        case value
        when String, Symbol
          normalized[:sound_license] = Set[ value.to_s.downcase ]
        when Enumerable
          normalized[:sound_license] = Set[*value.map { |v| v.to_s.downcase }]
        when nil
          # do nothing
        else
          raise ArgumentError, "Invalid value for 'sound_license': #{ value.inspect }"
        end
      when :licensed
        normalized[:licensed] = !!value unless value.nil?
      when :photo_licensed
        normalized[:photo_licensed] = !!value unless value.nil?
      when :sound_licensed
        normalized[:sound_licensed] = !!value unless value.nil?
      when :place_id, :place
        case value
        when INatGet::Models::Place
          normalized[:place_id] = Set[ value.id ]
        when Integer, String
          normalized[:place_id] = Set[ value ]
        when Enumerable
          normalized[:place_id] = Set[*value.map { |v| v.is_a?(INatGet::Models::Place) ? v.id : v }]
        when nil
          # do nothing
        else
          raise ArgumentError, "Invalid value for 'place_id': #{ value.inspect }"
        end
      when :project_id, :project
        case value
        when INatGet::Models::Project
          normalized[:project_id] = Set[ value.id ]
        when Integer, String
          normalized[:project_id] = Set[ value ]
        when Enumerable
          normalized[:project_id] = Set[*value.map { |v| v.is_a?(INatGet::Models::Project) ? v.id : v }]
        when nil
          # do nothing
        else
          raise ArgumentError, "Invalid value for 'project_id': #{ value.inspect }"
        end
      when :rank
        case value
        when String, Symbol
          normalized[:rank] = Set[ value.to_s.downcase ]
        when Enumerable
          normalized[:rank] = Set[*value.map { |v| v.to_s.downcase }]
        when nil
          # do nothing
        else
          raise ArgumentError, "Invalid value for 'rank': #{ value.inspect }"
        end
      when :taxon_id, :taxon
        case value
        when INatGet::Models::Taxon
          normalized[:taxon_id] = Set[ value.id ]
        when Integer, String
          normalized[:taxon_id] = Set[ value.to_i ]
        when Enumerable
          normalized[:taxon_id] = Set[*value.map { |v| v.is_a?(INatGet::Models::Taxon) ? v.id : v.to_i }]
        when nil
          # do nothing
        else
          raise ArgumentError, "Invalid value for 'taxon_id': #{ value.inspect }"
        end
      else
        raise ArgumentError, "Unsupported query parameter: #{ key }"
      end
    end
    @query = normalized
  end

  def eql? other
    self.query == other.query
  end

end

class INatGet::Logics::AndCondition < INatGet::Logics::Condition

  attr_reader :operands

  def initialize *operands
    operands.each { |op| raise ArgumentError, "Operand is not a condition: #{ op.inspect }", caller unless op.is_a?(Condition) }
    @operands = operands.uniq
  end

  def normalize
    result = ANYTHING
    @operands.each do |op|
      result &= op.normalize
    end
    if result.respond_to?(:operands)
      result.operands.uniq!
      return result.operands.first if result.operands.size == 1
      result.operands.each do |op1|
        result.operands.each do |op2|
          return NOTHING if op1.eql?(!op2)
        end
      end
    end
    result
  end

  def eql? other
    return false unless AndCondition === other
    Set[*@operands].eql? Set[*other.operands]
  end

  def & other
    if other.is_a?(AndCondition)
      AndCondition::new(*@operands, *other.operands)
    else
      AndCondition::new(*@operands, other)
    end
  end

  protected

  def dive
    AndCondition::new(*@operands.map { |o| o.dive })
  end

  def emerge 
    found = @operands.index { |o| o.is_a?(OrCondition) }
    if found
      items = operands.dup
      or_item = items.delete_at found
      rest = AndCondition::new(*items)
      and_items = or_item.operands.map { |o| (o & rest).normalize }
      OrCondition::new(*and_items).emerge
    else
      AndCondition::new(*@operands.map { |o| o.emerge }).normalize.deep_and
    end
  end

  def deep_and
    query_part, non_query_part = @operands.partition { |o| o.is_a?(QueryCondition) }
    not_part, rest_part = non_query_part.partition { |o| o.is_a?(NotCondition) && o.operand.is_a?(QueryCondition) }
    queries_operand = if !query_part.empty?
      queries_and(*query_part)
    else
      ANYTHING
    end
    not_queries_operand = if !not_part.empty?
      !queries_or(*not_part.map { |o| o.operand })
    else
      ANYTHING
    end
    rest_operand = if !rest_part.empty?
      AndCondition::new(*rest_part)
    else
      ANYTHING
    end
    AndCondition::new(queries_operand, not_queries_operand, rest_operand).normalize
  end

end

class INatGet::Logics::OrCondition < INatGet::Logics::Condition

  attr_reader :operands
  
  def initialize *operands
    operands.each { |op| raise ArgumentError, "Operand is not a condition: #{op.inspect}", caller unless op.is_a?(Condition) }
    @operands = operands.uniq
  end

  def normalize
    result = NOTHING
    @operands.each do |op|
      result |= op.normalize
    end
    if result.respond_to?(:operands)
      result.operands.uniq!
      return result.operands.first if result.operands.size == 1
      result.operands.each do |op1|
        result.operands.each do |op2|
          return ANYTHING if op1.eql?(!op2)
        end
      end
    end
    result
  end

  def eql? other
    return false unless OrCondition === other
    Set[*@operands].eql? Set[*other.operands]
  end

  def | other
    if other.is_a?(OrCondition)
      OrCondition::new(*@operands, *other.operands)
    else
      OrCondition::new(*@operands, other)
    end
  end

  protected

  def dive
    found = @operands.index { |o| o.is_a?(AndCondition) }
    if found
      items = @operands.dup
      and_item = items.delete_at found
      rest = OrCondition::new(*items)
      or_items = and_item.operands.map { |o| (o | rest).normalize }
      AndCondition::new(*or_items).dive
    else
      OrCondition::new(*@operands.map { |o| o.dive }).normalize.deep_or
    end
  end

  def emerge
    OrCondition::new(*@operands.map { |o| o.emerge })
  end

  def deep_or
    query_part, non_query_part = @operands.partition { |o| o.is_a?(QueryCondition) }
    not_part, rest_part = non_query_part.partition { |o| o.is_a?(NotCondition) && o.operand.is_a?(QueryCondition) }
    queries_operand = if !query_part.empty?
      queries_or(*query_part)
    else
      NOTHING
    end
    not_queries_operand = if !not_part.empty?
      !queries_and(*not_part.map { |o| o.operand })
    else
      NOTHING
    end
    rest_operand = if !rest_part.empty?
      OrCondition::new(*rest_part)
    else
      NOTHING
    end
    OrCondition::new(queries_operand, not_queries_operand, rest_operand).normalize
  end

end

class INatGet::Logics::NotCondition < INatGet::Logics::Condition

  attr_reader :operand

  def initialize operand
    @operand = operand
  end

  def normalize
    @operand = @operand.normalize
    case @operand
    when NotCondition
      @operand.operand
    when Nothing
      Anything
    when Anything
      Nothing
    else
      self
    end
  end

  def eql? other
    return false unless NotCondition === other
    @operand.eql? other.operand
  end

  def !
    @operand
  end

  protected

  def dive
    case @operand
    when AndCondition
      OrCondition::new(*@operand.operands.map { |o| !o }).dive
    when OrCondition
      AndCondition::new(*@operand.operands.map { |o| !o }).dive
    else
      self
    end
  end

end

class INatGet::Logics::Condition

  NOTHING  = INatGet::Logics::Nothing::instance
  ANYTHING = INatGet::Logics::Anything::instance

end



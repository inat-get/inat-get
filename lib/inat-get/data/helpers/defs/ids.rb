# frozen_string_literal: true

require_relative '../defs'

class INatGet::Data::Helper::Field::Ids < INatGet::Data::Helper::Field

  def initialize helper, key
    super helper, key
  end

  def prepare value
    case value
    when nil
      nil
    when Integer, String
      ::Set[ value ]
    when Enumerable
      value.to_set
    else 
      raise ArgumentError, "Invalid field value: #{ @key } => #{ value.inspect }", caller_locations
    end
  end

  def valid? value
    @sid ||= helper.manager.sid
    @uuid ||= helper.manager.uuid?
    return true if value.nil?
    return true if value.is_a?(Integer)
    return true if @sid && value.is_a?(String)
    return true if @uuid && value.is_a?(String) && value =~ INatGet::Data::Helper::UUID_PATTERN
    if value.is_a?(Enumerable)
      value.each do |v|
        next if v.is_a?(Integer)
        next if @sid && v.is_a?(String)
        next if @uuid && v.is_a?(String) && v =~ INatGet::Data::Helper::UUID_PATTERN
        return false
      end
      return true
    end
    return false
  end

  def to_sequel value
    return {} if value.nil?
    @sid ||= helper.manager.sid
    @uuid ||= helper.manager.uuid?
    result = []
    value.each do |v|
      result << { id: v } if v.is_a?(Integer)
      result << { uuid: v } if @uuid && v.is_a?(String) && v =~ INatGet::Data::Helper::UUID_PATTERN
      result << { @sid.to_sym => v } if @sid && v.is_a?(String)
    end
    Sequel.|(*result)
  end
    
end

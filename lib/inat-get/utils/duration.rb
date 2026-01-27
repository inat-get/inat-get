# frozen_string_literal: true

require_relative '../info'

module INatGet::Utils; end

module INatGet::Utils::Duration

  class << self

    def parse_duration source
      raise ArgumentError, "#{ source.inspect } is not a String", caller_locations unless source.is_a?(String)
      raise ArgumentError, "Empty string is not allowed", caller_locations if source.empty?
      raise ArgumentError, "#{source.inspect} is not a valid duration", caller_locations unless source =~ /^(\d+(w|d|h|m|s|ms|us|ns)\s*)+$/

      multipliers = {
        'w'  => 7 * 24 * 60 * 60,
        'd'  =>     24 * 60 * 60,
        'h'  =>          60 * 60,
        'm'  =>               60,
        's'  => 1,
        'ms' => 0.001,
        'us' => 0.000001,
        'ns' => 0.000000001
      }
      matches = source.scan(/(\d+)(w|d|h|m|s|ms|us|ns)/)
      seconds = 0
      subseconds = 0.0
      has_subseconds = false
      matches.each do |fields|
        num = fields[0].to_i
        unit = fields[1]
        if %w[ms us ns].include?(unit)
          subseconds += num * multipliers[unit]
          has_subseconds = true
        else
          seconds += num * multipliers[unit]
        end
      end
      if has_subseconds
        seconds + subseconds
      else
        seconds
      end
    end

    def as_duration source
      case source
      when Integer, Float
        source
      when String
        case source
        when /^\d+$/
          source.to_i
        when /^\d*\.\d*$/
          source.to_f
        else
          parse_duration source
        end
      else
        raise ArgumentError, "#{ source.inspect } is not a valid duration", caller_locations
      end
    end

  end

end


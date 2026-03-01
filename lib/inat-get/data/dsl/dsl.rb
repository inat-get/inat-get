# frozen_string_literal: true

require 'date'
require 'rubygems'

require_relative '../../info'
require_relative 'conditions'
require_relative '../types/rank'
require_relative '../types/iconic'

module INatGet::Data; end

module INatGet::Data::DSL

  include INatGet::Data::Enum

  # @group System Info

  # @return [Date]
  def today = Date.today

  # @return [Time]
  def now = Time.now

  # @return [Gem::Version]
  def version = Gem::Version::create INatGet::Info::VERSION

  # @return [String]
  def version_alias = INatGet::Info::VERSION_ALIAS

  # @return [Boolean]
  def version? *requirements
    requirement = Gem::Requirement::new(*requirements)
    requirement === version
  end

  # Returns `true` or raise exception
  # @return [true] or raise exception
  def version! *requirements
    raise Gem::DependencyError, "Invalid version: #{ INatGet::Info::VERSION }", caller_locations unless version?(*requirements)
    true
  end

  # @endgroup

  # @group Date Utils
  
  # @overload time_range date: nil
  #   @param [Date] date
  # @overload time_range century: nil
  #   @param [Integer] century Century (20 is 1901..2000)
  # @overload time_range century: nil, decade: nil
  #   @param [Integer] century
  #   @param [Integer] decade
  # @overload time_range year: nil
  #   @param [Integer] year
  # @overload time_range year: nil, quarter: nil
  #   @param [Integer] year
  #   @param [Integer] quarter
  # @overload time_range year: nil, season: nil
  #   @param [Integer] year
  #   @param [Symbol] season
  # @overload time_range year: nil, month: nil
  #   @param [Integer] year
  #   @param [Integer] month
  # @overload time_range year: nil, month: nil, day: nil
  #   @param [Integer] year
  #   @param [Integer] month
  #   @param [Integer] day
  # @overload time_range year: nil, week: nil
  #   @param [Integer] year
  #   @param [Integer] week
  # @overload time_range year: nil, day: nil
  #   @param [Integer] year
  #   @param [Integer] day
  # @see #start_time
  # @see #finish_time
  # @return [Range<Time>]
  def time_range date: nil, century: nil, decade: nil, year: nil, quarter: nil, season: nil, month: nil, day: nil, week: nil
    (start_time(date: date, century: century, decade: decade, year: year, quarter: quarter, season: season, month: month, day: day, week: week) ... finish_time(date: date, century: century, decade: decade, year: year, quarter: quarter, season: season, month: month, day: day, week: week))
  end

  # @overload start_time date: nil
  #   @param [Date] date
  # @overload start_time century: nil
  #   @param [Integer] century
  # @overload start_time century: nil, decade: nil
  #   @param [Integer] century
  #   @param [Integer] decade
  # @overload start_time year: nil
  #   @param [Integer] year
  # @overload start_time year: nil, quarter: nil
  #   @param [Integer] year
  #   @param [Integer] quarter
  # @overload start_time year: nil, season: nil
  #   @param [Integer] year
  #   @param [Symbol] season
  # @overload start_time year: nil, month: nil
  #   @param [Integer] year
  #   @param [Integer] month
  # @overload start_time year: nil, month: nil, day: nil
  #   @param [Integer] year
  #   @param [Integer] month
  #   @param [Integer] day
  # @overload start_time year: nil, week: nil
  #   @param [Integer] year
  #   @param [Integer] week
  # @overload start_time year: nil, day: nil
  #   @param [Integer] year
  #   @param [Integer] day
  # @see #time_range
  # @see #finish_time
  # @return [Time]
  def start_time date: nil, century: nil, decade: nil, year: nil, quarter: nil, season: nil, month: nil, day: nil, week: nil
    if date
      raise ArgumentError, "Too many arguments", caller_locations if century || decade || year || quarter || season || month || day || week
      date.to_time
    elsif century
      raise ArgumentError, "Too many arguments", caller_locations if year || quarter || season || month || day || week
      start_time year: ((century - 1) * 100 + (decade || 0) * 10 + 1)
    elsif year && quarter
      raise ArgumentError, "Too many arguments", caller_locations if season || month || day || week
      start_time year: year, month: ((quarter - 1) * 3 + 1)
    elsif year && season
      raise ArgumentError, "Too many arguments", caller_locations if month || day || week
      case season
      when :winter
        start_time year: (year - 1), month: 12
      when :spring
        start_time year: year, month: 3
      when :summer
        start_time year: year, month: 6
      when :autumn
        start_time year: year, month: 9
      else
        raise ArgumentError, "Invalid season: #{ season.inspect }", caller_locations
      end
    elsif year && month
      raise ArgumentError, "Too many arguments", caller_locations if week
      date = Date::civil year, month, (day || 1)
      start_time date: date
    elsif year && week
      date = Date::commercial year, week, (day || 1)
      start_time date: date
    elsif year && day
      date = Date::ordinal year, day
      start_time date: date
    elsif year
      start_time year: year, month: 1, day: 1
    else
      raise ArgumentError, "Incorrect or empty arguments", caller_locations
    end
  end

  # @overload finish_time date: nil
  #   @param [Date] date
  # @overload finish_time century: nil
  #   @param [Integer] century
  # @overload finish_time century: nil, decade: nil
  #   @param [Integer] century
  #   @param [Integer] decade
  # @overload finish_time year: nil
  #   @param [Integer] year
  # @overload finish_time year: nil, quarter: nil
  #   @param [Integer] year
  #   @param [Integer] quarter
  # @overload finish_time year: nil, season: nil
  #   @param [Integer] year
  #   @param [Symbol] season
  # @overload finish_time year: nil, month: nil
  #   @param [Integer] year
  #   @param [Integer] month
  # @overload finish_time year: nil, month: nil, day: nil
  #   @param [Integer] year
  #   @param [Integer] month
  #   @param [Integer] day
  # @overload finish_time year: nil, week: nil
  #   @param [Integer] year
  #   @param [Integer] week
  # @overload finish_time year: nil, day: nil
  #   @param [Integer] year
  #   @param [Integer] day
  # @see #time_range
  # @see #start_time
  # @return [Time]
  def finish_time date: nil, century: nil, decade: nil, year: nil, quarter: nil, season: nil, month: nil, day: nil, week: nil
    if date
      raise ArgumentError, "Too many argument", caller_locations if century || decade || year || quarter || season || month || day || week
      start_time date: (date + 1)
    elsif century
      raise ArgumentError, "Too many argument", caller_locations if year || quarter || season || month || day || week
      if decade
        start_time century: century, decade: (decade + 1)
      else
        start_time century: (century + 1)
      end
    elsif year && quarter
      raise ArgumentError, "Too many argument", caller_locations if season || month || day || week
      finish_time year: year, month: (quarter * 3)
    elsif year && season 
      raise ArgumentError, "Too many argument", caller_locations if month || day || week
      case season
      when :winter
        finish_time year: year, month: 2
      when :spring
        finish_time year: year, month: 5
      when :summer
        finish_time year: year, month: 8
      when :autumn
        finish_time year: year, month: 11
      else
        raise ArgumentError, "Invalid season: #{ season.inspect }", caller_locations
      end
    elsif year && month
      raise ArgumentError, "Too many arguments", caller_locations if week
      date = Date::civil year, month, (day || -1)
      finish_time date: date
    elsif year && week
      date = Date::commercial year, week, (day || -1)
      finish_time date: date
    elsif year && day
      date = Date::ordinal year, day
      finish_time date: date
    elsif year
      finish_time year: year, month: 12, day: 31
    else
      raise ArgumentError, "Incorrect or empty arguments", caller_locations
    end
  end

  # @endgroup

end

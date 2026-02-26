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

  # @return [DateTime]
  def now = DateTime.now

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
  
  # @overload range date: 
  #   @param [Date] date
  # @overload range century:
  #   @param [Integer] century
  # @overload range century:, decade:
  #   @param [Integer] century
  #   @param [Integer] decade
  # @overload range year:
  #   @param [Integer] year
  # @overload range year:, quarter:
  #   @param [Integer] year
  #   @param [Integer] quarter
  # @overload range year:, season:
  #   @param [Integer] year
  #   @param [Symbol] season
  # @overload range year:, month:
  #   @param [Integer] year
  #   @param [Integer] month
  # @overload range year:, month:, day:
  #   @param [Integer] year
  #   @param [Integer] month
  #   @param [Integer] day
  # @overload range year:, week:
  #   @param [Integer] year
  #   @param [Integer] week
  # @overload range year:, day:
  #   @param [Integer] year
  #   @param [Integer] day
  # @see #start
  # @see #finish
  # @return [Range<DateTime>]
  def range date: nil, century: nil, decade: nil, year: nil, quarter: nil, season: nil, month: nil, day: nil, week: nil
    (start(date: date, century: century, decade: decade, year: year, quarter: quarter, season: season, month: month, day: day, week: week) ... finish(date: date, century: century, decade: decade, year: year, quarter: quarter, season: season, month: month, day: day, week: week))
  end

  # @overload start date:
  #   @param [Date] date
  # @overload start century:
  #   @param [Integer] century
  # @overload start century:, decade:
  #   @param [Integer] century
  #   @param [Integer] decade
  # @overload start year:
  #   @param [Integer] year
  # @overload start year:, quarter:
  #   @param [Integer] year
  #   @param [Integer] quarter
  # @overload start year:, season:
  #   @param [Integer] year
  #   @param [Symbol] season
  # @overload start year:, month:
  #   @param [Integer] year
  #   @param [Integer] month
  # @overload start year:, month:, day:
  #   @param [Integer] year
  #   @param [Integer] month
  #   @param [Integer] day
  # @overload start year:, week:
  #   @param [Integer] year
  #   @param [Integer] week
  # @overload start year:, day:
  #   @param [Integer] year
  #   @param [Integer] day
  # @see #range
  # @see #finish
  # @return [DateTime]
  def start date: nil, century: nil, decade: nil, year: nil, quarter: nil, season: nil, month: nil, day: nil, week: nil
    if date
      raise ArgumentError, "Too many arguments", caller_locations if century || decade || year || quarter || season || month || day || week
      date.to_datetime
    elsif century
      raise ArgumentError, "Too many arguments", caller_locations if year || quarter || season || month || day || week
      start year: ((century - 1) * 100 + (decade || 0) * 10 + 1)
    elsif year && quarter
      raise ArgumentError, "Too many arguments", caller_locations if season || month || day || week
      start year: year, month: ((quarter - 1) * 3 + 1)
    elsif year && season
      raise ArgumentError, "Too many arguments", caller_locations if month || day || week
      case season
      when :winter
        start year: (year - 1), month: 12
      when :spring
        start year: year, month: 3
      when :summer
        start year: year, month: 6
      when :autumn
        start year: year, month: 9
      else
        raise ArgumentError, "Invalid season: #{ season.inspect }", caller_locations
      end
    elsif year && month
      raise ArgumentError, "Too many arguments", caller_locations if week
      date = Date::civil year, month, (day || 1)
      start date: date
    elsif year && week
      date = Date::commercial year, week, (day || 1)
      start date: date
    elsif year && day
      date = Date::ordinal year, day
      start date: date
    elsif year
      start year: year, month: 1, day: 1
    else
      raise ArgumentError, "Incorrect or empty arguments", caller_locations
    end
  end

  # @overload finish date:
  #   @param [Date] date
  # @overload finish century:
  #   @param [Integer] century
  # @overload finish century:, decade:
  #   @param [Integer] century
  #   @param [Integer] decade
  # @overload finish year:
  #   @param [Integer] year
  # @overload finish year:, quarter:
  #   @param [Integer] year
  #   @param [Integer] quarter
  # @overload finish year:, season:
  #   @param [Integer] year
  #   @param [Symbol] season
  # @overload finish year:, month:
  #   @param [Integer] year
  #   @param [Integer] month
  # @overload finish year:, month:, day:
  #   @param [Integer] year
  #   @param [Integer] month
  #   @param [Integer] day
  # @overload finish year:, week:
  #   @param [Integer] year
  #   @param [Integer] week
  # @overload finish year:, day:
  #   @param [Integer] year
  #   @param [Integer] day
  # @see #range
  # @see #start
  # @return [DateTime]
  def finish date: nil, century: nil, decade: nil, year: nil, quarter: nil, season: nil, month: nil, day: nil, week: nil
    if date
      raise ArgumentError, "Too many argument", caller_locations if century || decade || year || quarter || season || month || day || week
      start date: (date + 1)
    elsif century
      raise ArgumentError, "Too many argument", caller_locations if year || quarter || season || month || day || week
      if decade
        start century: century, decade: (decade + 1)
      else
        start century: (century + 1)
      end
    elsif year && quarter
      raise ArgumentError, "Too many argument", caller_locations if season || month || day || week
      finish year: year, month: (quarter * 3)
    elsif year && season 
      raise ArgumentError, "Too many argument", caller_locations if month || day || week
      case season
      when :winter
        finish year: year, month: 2
      when :spring
        finish year: year, month: 5
      when :summer
        finish year: year, month: 8
      when :autumn
        finish year: year, month: 11
      else
        raise ArgumentError, "Invalid season: #{ season.inspect }", caller_locations
      end
    elsif year && month
      raise ArgumentError, "Too many arguments", caller_locations if week
      date = Date::civil year, month, (day || -1)
      finish date: date
    elsif year && week
      date = Date::commercial year, week, (day || -1)
      finish date: date
    elsif year && day
      date = Date::ordinal year, day
      finish date: date
    elsif year
      finish year: year, month: 12, day: 31
    else
      raise ArgumentError, "Incorrect or empty arguments", caller_locations
    end
  end

  # @endgroup

end

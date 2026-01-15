# frozen_string_literal: true

require_relative '../info'
require_relative '../utils/boolean'

module INatGet::Data; end
module INatGet::Data::Helpers; end

module INatGet::Data::Helpers::Common

  def get_project id_or_slug
    # TODO: implement
  end

  def get_place id_or_slug
    # TODO: implement
  end

  def get_taxon id
    # TODO: implement
  end

  def get_user id_or_login
    # TODO: implement
  end

  module_function :get_project, :get_place, :get_taxon, :get_user

  def prepare_query **query
    result = {}
    query.each do |key, value|
      next if value.nil?
      key = key.to_sym
      func = query_funcs[key]
      raise ArgumentError, "Invalid query key: #{ key }", caller_locations if type.nil?
      value = func.call key, value
      case value
      when nil
        # do nothing
      when Hash
        result.merge! value
      else
        result[key] = value
      end
    end
    result
  end

  def query_funcs
    {}
  end

  private

  def scalar_func check, convert = nil
    @funcs ||= {}
    @funcs[[:scalar, check, convert]] ||= lambda do |key, value|
      message = "Invalid query parameter value (check for #{ check.inspect }): #{ key } => #{ value.inspect }"
      if check === value
        value
      elsif convert
        v = convert[value]
        raise ArgumentError, message, caller_locations unless check === v
        v
      else
        raise ArgumentError, message, caller_locations 
      end
    end
  end

  def set_func check, convert = nil
    @funcs ||= {}
    @funcs[[:set, check, convert]] ||= lambda do |key, value|
      message = "Invalid query parameter value (check for #{ check.inspect }): #{ key } => #{ value.inspect }"
      if check === value
        [ value ].to_set
      elsif Enumerable === value
        value.map do |v|
          if check === v
            v
          elsif convert
            vv = convert[v]
            raise ArgumentError, message, caller_locations unless check === vv
            vv
          else
            raise ArgumentError, message, caller_locations
          end
        end.to_set
      elsif convert
        vv = convert[v]
        raise ArgumentError, message, caller_locations unless check === vv
        vv
      else
        raise ArgumentError, message, caller_locations 
      end
    end
  end

  def range_func check, convert = nil, begin_convert = nil, end_convert = nil
    @funcs ||= {}
    @funcs[[:range, check, convert, begin_convert, end_convert]] ||= lambda do |key, value|
      message = "Invalid query parameter value (check for #{ check.inspect }): #{ key } => #{ value.inspect }"
      if Range === value
        unless value.begin.nil? || check === value.begin
          if begin_convert
            v = begin_convert[value.begin]
            raise ArgumentError, message, caller_locations unless v.nil? || check === v
            value = Range::new v, value.end, value.exclude_end?
          else
            raise ArgumentError, message, caller_locations
          end
        end
        unless value.end.nil? || check === value.end
          if end_convert
            v = end_convert[value.end]
            raise ArgumentError, message, caller_locations unless v.nil? || check === v
            value = Range::new value.begin, v, value.exclude_end?
          else
            raise ArgumentError, message, caller_locations
          end
        end
        value
      else
        v = convert[value]
        unless Range === v && (v.begin.nil? || check === v.begin) && (v.end.nil? || check === v.end)
          raise ArgumentError, message, caller_locations
        end
        v
      end
    end
  end

  def time_range_func
    convert = lambda do |value|
      if value.is_a?(Date)
        (value.to_time .. (value + 1).to_time)
      else
        value
      end
    end
    begin_convert = lambda do |value|
      if value.is_a?(Date)
        value.to_time
      else
        value
      end
    end
    end_convert = lambda do |value|
      if value.is_a?(Date)
        (value + 1).to_time
      else
        value
      end
    end
    range_func(Time, convert, begin_convert, end_convert)
  end

  def scalar_or_range_func(check, convert = nil, begin_convert = nil, end_convert = nil)
    @funcs ||= {}
    @funcs[[:scalar_or_range, check, convert, begin_convert, end_convert]] ||= lambda do |key, value|
      message = "Invalid query parameter value (check for #{ check.inspect }): #{ key } => #{ value.inspect }"
      if Range === value
        unless value.begin.nil? || check === value.begin
          if begin_convert
            v = begin_convert[value.begin]
            raise ArgumentError, message, caller_locations unless v.nil? || check === v
            value = Range::new v, value.end, value.exclude_end?
          else
            raise ArgumentError, message, caller_locations
          end
        end
        unless value.end.nil? || check === value.end
          if end_convert
            v = end_convert[value.end]
            raise ArgumentError, message, caller_locations unless v.nil? || check === v
            value = Range::new value.begin, v, value.exclude_end?
          else
            raise ArgumentError, message, caller_locations
          end
        end
        value
      else
        v = convert[value]
        raise ArgumentError, message, caller_locations unless check === v
        v
      end
    end
  end

  def set_or_range_func check, convert = nil, begin_convert = nil, end_convert = nil
    @funcs ||= {}
    @funcs[[:set_or_range, check, convert, begin_convert, end_convert]] ||= lambda do |key, value|
      message = "Invalid query parameter value (check for #{ check.inspect }): #{ key } => #{ value.inspect }"
      case value
      when check
        [ value ].to_set
      when Range
        unless value.begin.nil? || check === value.begin
          if begin_convert
            v = begin_convert[value.begin]
            raise ArgumentError, message, caller_locations unless v.nil? || check === v
            value = Range::new v, value.end, value.exclude_end?
          else
            raise ArgumentError, message, caller_locations
          end
        end
        unless value.end.nil? || check === value.end
          if end_convert
            v = end_convert[value.end]
            raise ArgumentError, message, caller_locations unless v.nil? || check === v
            value = Range::new value.begin, v, value.exclude_end?
          else
            raise ArgumentError, message, caller_locations
          end
        end
        value
      when Enumerable
        value.map do |v|
          if check === v
            v
          elsif convert
            vv = convert[v]
            raise ArgumentError, message, caller_locations unless vv.nil? || check === vv
            vv
          else
            raise ArgumentError, message, caller_locations
          end
        end.to_set
      else
        v = convert[value]
        raise ArgumentError, message, caller_locations unless v.nil? || check === v
        [ v ].to_set
      end
    end
  end

  def rank_set_or_range_func
    convert = lambda do |value|
      INatGet::Enums::Rank::of value
    end
    set_or_range_func(INatGet::Enums::Rank, convert, convert, convert)
  end

  def location_field_func
    lambda do |key, value|
      {
        latitude: scalar_func(Float).call(key, value[0]),
        longitude: scalar_func(Float).call(key, value[1]),
      }
    end
  end

end

class INatGet::Data::Helpers::Observation

  include Singleton
  include INatGet::Data::Helpers::Common

  def query_funcs
    @query_types ||= {
                   id: set_func(Integer),
              captive: scalar_func(Boolean),
              endemic: scalar_func(Boolean),
                  geo: scalar_func(Boolean),
           identified: scalar_func(Boolean),
           introduced: scalar_func(Boolean),
             mappable: scalar_func(Boolean),
               native: scalar_func(Boolean),
         out_of_range: scalar_func(Boolean),
              popular: scalar_func(Boolean),
               photos: scalar_func(Boolean),
               sounds: scalar_func(Boolean),
      taxon_is_active: scalar_func(Boolean),
           threatened: scalar_func(Boolean),
           verifiable: scalar_func(Boolean),
             licensed: scalar_func(Boolean),
       photo_licensed: scalar_func(Boolean),
       sound_licensed: scalar_func(Boolean),
              license: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
        photo_license: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
        sound_license: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
                place: set_func(INatGet::Models::Place, lambda { |v| get_place(v) }),
              project: set_func(INatGet::Models::Project, lambda { |v| get_project(v) }),
                 rank: rank_set_or_range_func,
                taxon: set_func(INatGet::Models::Taxon, lambda { |v| get_taxon(v) }),
                 user: set_func(INatGet::Models::User, lambda { |v| get_user(v) }),
        observed_year: set_func(Integer),
       observed_month: set_func(Integer),
         observed_day: set_func(Integer),
        observed_hour: set_func(Integer),
         created_year: set_func(Integer),
        created_month: set_func(Integer),
          created_day: set_func(Integer),
         created_hour: set_func(Integer),
             accuracy: range_func(Integer),
                 date: date_field_func,
             observed: time_range_func,
              created: time_range_func,
                  csi: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
           geoprivacy: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
     taxon_geoprivacy: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
          obscuration: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
          iconic_taxa: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
             latitude: scalar_or_range_func(Float),
            longitude: scalar_or_range_func(Float),
             location: location_field_func,
               radius: scalar_func(Float),
        quality_grade: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v })
    }.freeze
  end

  private

  def date_field_func
    lambda do |key, value|
      { observed: time_range_func.call(key, value) }
    end
  end

end

class INatGet::Data::Helpers::Taxon

  include Singleton
  include INatGet::Data::Helpers::Common

  def query_funcs
    @query_funcs ||= {
             id: set_func(Integer),
         parent: scalar_func(INatGet::Models::Taxon, lambda { |v| get_taxon(v) }),
      is_active: scalar_func(Boolean),
           rank: rank_set_or_range_func
    }.freeze
  end

end

class INatGet::Data::Helpers::Project

  include Singleton
  include INatGet::Data::Helpers::Common

  def query_funcs
    @query_funcs ||= {
             id: set_func(Integer),
           slug: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
           type: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
          place: set_func(INatGet::Models::Place, lambda { |v| get_place(v) }),
       latitude: scalar_func(Float),
      longitude: scalar_func(Float),
       location: location_field_func,
         radius: scalar_func(Float)
    }.freeze
  end

end

class INatGet::Data::Helpers::Place

  include Singleton
  include INatGet::Data::Helpers::Common

  def query_funcs
    @query_funcs ||= {
             id: set_func(Integer),
           slug: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v }),
       latitude: scalar_or_range_func(Float),
      longitude: scalar_or_range_func(Float),
       location: location_field_func
    }.freeze
  end

end

class INatGet::Data::Helpers::User

  include Singleton
  include INatGet::Data::Helpers::Common

  def query_funcs
    @query_funcs ||= {
         id: set_func(Integer),
      login: set_func(String, lambda { |v| v.is_a?(Symbol) ? v.to_s : v })
    }.freeze
  end

end

module INatGet::Data::Helpers

  OBS = INatGet::Data::Helpers::Observation::instance
  TXN = INatGet::Data::Helpers::Taxon::instance
  PRJ = INatGet::Data::Helpers::Project::instance
  PLC = INatGet::Data::Helpers::Place::instance

end

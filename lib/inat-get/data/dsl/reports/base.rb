# frozen_string_literal: true

require_relative '../../../info.rb'
require_relative '../dsl'

class INatGet::Data::DSL::Report

  include INatGet::Data::DSL

  def initialize mode: nil, suffix: nil, **data
    @mode = mode
    @data = data
    @suffix = suffix
    yield self if block_given?
  end

  # @return [String]
  def basename suffix = nil
    suffix ||= @suffix
    if suffix
      self.name + ' -- ' + suffix
    else
      self.name
    end
  end

  # @return [String]
  def ext mode: nil
    (mode || @mode)&.to_s
  end

  # @return [String]
  def filename suffix: nil, mode: nil
    if self.ext(mode: mode)
      self.basename(suffix) + '.' + self.ext(mode: mode)
    else
      self.basename(suffix)
    end
  end

  # @return [String]
  def render mode: nil
    raise NotImplementedError, "Not implemented method 'render' for abstract Report", caller_locations
  end

  # @return [void]
  def save filename = nil, suffix: nil, mode: nil
    filename ||= self.filename(suffix: suffix, mode: mode)
    File.write filename, self.render(mode: mode)
  end

  def [] key
    @data[key]
  end

  def []= key, value
    @data[key] = value
  end

end

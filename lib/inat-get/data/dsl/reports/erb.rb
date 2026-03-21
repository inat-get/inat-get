# frozen_string_literal: true

require 'erb'

require_relative 'base'

class INatGet::Data::DSL::Report::ERB < INatGet::Data::DSL::Report

  def initialize code = nil, file: nil, ext: nil, trim_mode: nil, suffix: nil, **data, &block
    @code = code
    @code ||= File.read(file) if file
    raise ArgumentError, "Source not specified", caller_locations unless @code
    @ext = ext
    @ext ||= File.extname(File.basename(file, '.erb')) if file
    @erb = ::ERB::new @code, trim_mode: trim_mode
    @erb.filename = file || '(erb)'
    suffix ||= File.basename(File.basename(file, '.erb'), '.*') if file
    super(mode: nil, suffix: suffix, **data, &block)
  end

  # @return [Hash]
  attr_reader :data

  # @return [String]
  def ext mode: nil
    @ext
  end

  # @return [String]
  def render
    @erb.result binding
  end

end

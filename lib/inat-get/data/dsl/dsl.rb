# frozen_string_literal: true

require 'date'
require 'rubygems'

require_relative '../../info'
require_relative 'conditions'

module INatGet::Data; end

module INatGet::Data::DSL

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

end

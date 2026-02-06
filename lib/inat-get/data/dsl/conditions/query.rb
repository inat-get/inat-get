# frozen_string_literal: true

require_relative 'base'
require_relative '../../helper'

class INatGet::Data::DSL::Condition::Q < INatGet::Data::DSL::Condition::Base

  attr_reader :query

  def initialize helper, **query
    @helper = helper
    @query = query
  end

  def helper
    @helper
  end

  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(Q)
    self.query == other.query && self.helper == other.helper
  end

  class Maker

    attr_reader :helper

    def initialize helper
      @helper = helper
    end

    def [] **query
      return ANYTHING if query.empty?
      INatGet::Data::DSL::Condition::Q[@helper, **query]
    end
  end

  private_constant :Maker

  class << self

    private def maker helper
      @makers ||= {}
      @makers[helper] ||= Maker::new(helper).freeze
    end

    def [] helper, **query
      return maker(helper) if query.empty?
      new(helper, **query).freeze
    end

    private :new

  end

  def merge_n_factor
    Q[@helper][ **@helper.prepare_query(**@query) ]
  end

  def to_api
    @helper.to_api(**@query)
  end

  def to_sequel
    @helper.to_sequel(**@query)
  end

end

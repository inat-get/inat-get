# frozen_string_literal: true

require_relative 'base'
require_relative '../../helper'

class INatGet::Data::DSL::Condition::Query < INatGet::Data::DSL::Condition

  # @group Metadata

  # @api private
  # @return [Hash]
  attr_reader :query
  
  # @api private
  # @return [class of Sequel::Model]
  attr_reader :model

  # @endgroup

  # @private
  def initialize model, **query
    @model = model
    @helper = model.helper
    @query = query
  end

  # @group Operators

  # @return [Boolean]
  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(Q)
    self.query == other.query && self.helper == other.helper
  end

  # @endgroup

  class << self

    # @private
    private def creator model
      @creators ||= {}
      @creators[model] ||= lambda { |**query| self[model, **query] }
    end

    # @group Constructor

    # @return [Condition]
    def [] model, **query
      return creator(model) if query.empty?
      new(model, **query).freeze
    end

    # @endgroup

    private :new

  end

  # @private
  def merge_n_factor
    Q[@model][ **@helper.prepare_query(**@query) ]
  end

  # @private
  def to_api
    @helper.to_api(**@query)
  end

  # @private
  def to_sequel
    @helper.to_sequel(**@query)
  end

end

module INatGet::Data::DSL

  # @group Conditions

  # @return [Condition::Query]
  # @overload Q model
  #   Return procedure which return {Condition::Query}.
  #   @param [INatGet::Data::Model::Base] model
  #   @return [Proc<Hash => Condition::Query>]
  # @overload Q model, **query
  #   @param [INatGet::Data::Model::Base] model
  #   @param [Hash] query
  # @overload Q **query
  #   If _model_ parameter is emitted, {INatGet::Data::Model::Observation} is used by default.
  #   @param [Hash] query
  private def Q(model = INatGet::Data::Model::Observation, **query) = Condition::Query[model, **query]

  # @endgroup

end

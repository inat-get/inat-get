# frozen_string_literal: true

require_relative 'base'
require_relative '../../helpers/base'

class INatGet::Data::DSL::Condition::Query < INatGet::Data::DSL::Condition

  # @group Metadata

  # @api private
  # @return [Hash]
  attr_reader :query
  
  # @api private
  # @return [class of Sequel::Model]
  attr_reader :model

  # @api private
  # @return [INatGet::Data::Helper]
  attr_reader :helper

  # @endgroup

  # @private
  def initialize model, validate: true, **query
    @model = model
    @helper = model.helper
    @helper.validate_query!(**query) if validate
    @query = query
  end

  # @group Operators

  # @return [Boolean]
  def == other
    return true if self.equal?(other)
    return false unless other.is_a?(Query)
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
    def [] model, validate: true, **query
      return creator(model) if query.empty?
      new(model, validate: validate, **query).freeze
    end

    # @endgroup

    private :new

  end

  # @private
  def expand_references
    self.translate_projects
  end

  # @private
  def merge_n_factor
    Query[ @model, validate: false, **@helper.prepare_query(**@query) ]
  end

  # @private
  def to_api
    @helper.query_to_api(**@query)
  end

  # @private
  def to_sequel
    @helper.query_to_sequel(**@query)
  end

  private

  # @private
  def translate_projects mode = :config
    return self unless @query.has_key?(:project)
    mode = INatGet::App::Setup::config.dig :api, :translate_projects if mode == :config
    mode = 'none' if mode.nil?
    mode = mode.to_s.freeze
    return self if mode == 'none'
    
    work_query = @query.dup
    projects = Set[ *work_query.delete(:project) ]
    umbrellas, rest = projects.partition { |p| p.is_umbrella }
    projects = rest + umbrellas.map(&:subprojects).flatten
    if mode == 'all'
      collections, rest = projects.partition { |p| p.is_collection }
      if collections.empty?
        work_query[:project] = projects
        return Query[ @model, validate: false, **work_query ]
      end
      collection_conditions = collections.map do |c|
        conditions = []
        conditions << Query[@model, validate: false, place: c.included_places ] unless c.included_places.empty?
        conditions << NOT[ Query[@model, validate: false, place: c.excluded_places ] ] unless c.excluded_places.empty?
        conditions << Query[@model, validate: false, taxon: c.included_taxa ] unless c.included_taxa.empty?
        conditions << NOT[ Query[@model, validate: false, taxon: c.excluded_taxa ] ] unless c.excluded_taxa.empty?
        if c.members_only
          conditions << Query[@model, validate: false, user: c.members ]
        else
          conditions << Query[@model, validate: false, user: c.included_users ] unless c.included_users.empty?
        end
        conditions << NOT[ Query[@model, validate: false, user: c.excluded_users ] ] unless c.excluded_users.empty?
        unless c.terms.empty?
          c.terms.each do |term|
            conditions << Query[@model, validate: false, term_id: term.term_id, term_value_id: term.term_value_id ]
          end
        end
        AND[ *conditions ]
      end
      AND[ Query[@model, validate: false, **work_query ], OR[ Query[@model, validate: false, project: rest ], *collection_conditions ] ]
    else
      work_query[:project] = projects
      Query[@model, validate: false, **work_query ]
    end
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
  def Q(model = INatGet::Data::Model::Observation, **query) = Condition::Query[ model, validate: true, **query ]

  # @endgroup

end

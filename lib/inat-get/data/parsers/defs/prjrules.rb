# frozen_string_literal: true

require_relative '../defs'
require_relative '../../models/projectplace'
require_relative '../../models/projecttaxon'
require_relative '../../models/projectuser'

class INatGet::Data::Parser::Part::PrjRules < INatGet::Data::Parser::Part::Assoc

  def initialize parser
    super parser, nil, model: nil
  end

  # @return [nil]
  def parse target, source
    return nil unless target.is_collection
    included_places = []
    excluded_places = []
    included_users = []
    excluded_users = []
    included_taxa = []
    excluded_taxa = []
    rules = source[:project_observation_rules] || []
    rules.each do |rule|
      id = rule[:operand_id]
      next unless id
      case rule[:operator]
      when 'observed_in_place?'
        included_places << id
      when 'not_observed_in_place?'
        excluded_places << id
      when 'observed_in_taxon?'
        included_taxa << id
      when 'not_observed_in_taxon?'
        excluded_taxa << id
      when 'observed_by_user?'
        included_users << id
      when 'not_observed_in_user?'
        excluded_users << id
      end
    end
    # Fetch objects & ignore inaccessible
    included_places = p_man.get(*included_places).compact.map(&:id)
    excluded_places = p_man.get(*excluded_places).compact.map(&:id)
    included_users = u_man.get(*included_users).compact.map(&:id)
    excluded_users = u_man.get(*excluded_users).compact.map(&:id)
    included_taxa = t_man.get(*included_taxa).compact.map(&:id)
    excluded_taxa = t_man.get(*excluded_taxa).compact.map(&:id)
    update_rules target.id, pp_mod, :place_id, included_places, false
    update_rules target.id, pp_mod, :place_id, excluded_places, true
    update_rules target.id, pt_mod, :taxon_id, included_taxa, false
    update_rules target.id, pt_mod, :taxon_id, excluded_taxa, true
    update_rules target.id, pu_mod, :user_id, included_users, false
    update_rules target.id, pu_mod, :user_id, excluded_users, true
    nil
  end

  private

  # @private
  def update_rules p_id, model, key, ids, exclude
    condition = Sequel.&({ project_id: p_id, exclude: exclude }, Sequel.~({ key => ids }))
    model.where(condition).delete
    ids.each do |id|
      record = model.with_pk([ p_id, id ])
      if record
        record.update(exclude: exclude) || record
      else
        model.create :project_id => p_id, key => id, :exclude => exclude
      end
    end
  end

  # @private
  def p_man() = INatGet::Data::Manager::Places::instance

  # @private
  def u_man() = INatGet::Data::Manager::Users::instance

  # @private
  def t_man() = INatGet::Data::Manager::Taxa::instance

  # @private
  def pp_mod() = INatGet::Data::Model::ProjectPlace

  # @private
  def pu_mod() = INatGet::Data::Model::ProjectUser

  # @private
  def pt_mod() = INatGet::Data::Model::ProjectTaxon

end

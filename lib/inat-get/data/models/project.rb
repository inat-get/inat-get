# frozen_string_literal: true

require 'sequel'

require_relative '../../info'
require_relative 'observation'
require_relative 'annotation'
require_relative 'projectadmin'
require_relative 'projectqualitygrade'
require_relative 'projectterm'

module INatGet::Data; end

class INatGet::Data::Model::Project < INatGet::Data::Model

  set_dataset :projects

  many_to_one :user, class: :'INatGet::Data::Model::User'

  many_to_many :manual_observations, class: :'INatGet::Data::Model::Observation', join_table: :observation_projects, left_key: :project_id, right_key: :observation_id

  many_to_many :included_taxa, class: :'INatGet::Data::Model::Taxon', join_table: :project_included_taxa, left_key: :project_id, right_key: :taxon_id
  many_to_many :excluded_taxa, class: :'INatGet::Data::Model::Taxon', join_table: :project_excluded_taxa, left_key: :project_id, right_key: :taxon_id
  many_to_many :included_places, class: :'INatGet::Data::Model::Place', join_table: :project_included_places, left_key: :project_id, right_key: :place_id
  many_to_many :excluded_places, class: :'INatGet::Data::Model::Place', join_table: :project_excluded_places, left_key: :project_id, right_key: :place_id
  many_to_many :included_users, class: :'INatGet::Data::Model::User', join_table: :project_included_users, left_key: :project_id, right_key: :user_id
  many_to_many :excluded_users, class: :'INatGet::Data::Model::User', join_table: :project_excluded_users, left_key: :project_id, right_key: :user_id

  many_to_many :subprojects, class: self, join_table: :umbrella_projects, left_key: :umbrella_id, right_key: :subproject_id

  many_to_many :members, class: :'INatGet::Data::Model::User', join_table: :project_members, left_key: :project_id, right_key: :user_id

  one_to_many :admins, class: :'INatGet::Data::Model::ProjectAdmin'
  one_to_many :quality_grades, class: :'INatGet::Data::Model::ProjectQualityGrade'
  one_to_many :terms, class: :'INatGet::Data::Model::ProjectTerm'

  # @api private
  one_to_many :taxa, class: :'INatGet::Data::Model::ProjectTaxon'

  # @api private
  one_to_many :places, class: :'INatGet::Data::Model::ProjectPlace'

  # @api private
  one_to_many :users, class: :'INatGet::Data::Model::ProjectUser'

  # @return [Sequel::SQL::Expression]
  def to_sequel
    if self.is_umbrella
      return Sequel.|(*self.subprojects.map(&:to_sequel))
    elsif self.is_collection
      conditions = []
      if !self.included_taxa_dataset.empty?
        conditions << Sequel.|(*self.included_taxa.map { |taxon| { taxon: taxon.descendants_dataset } })
      end
      if !self.excluded_taxa_dataset.empty?
        conditions << Sequel.~(Sequel.|(*self.excluded_taxa.map { |taxon| { taxon: taxon.descendants_dataset } }))
      end
      if !self.included_places_dataset.empty?
        conditions << { places: self.included_places_dataset }
      end
      if !self.excluded_places_dataset.empty?
        conditions << Sequel.~({ places: self.excluded_places_dataset })
      end
      if self.members_only
        conditions << { user: self.members_dataset }
      elsif !self.included_users_dataset.empty?
        conditions << { user: self.included_users_dataset }
      end
      if !self.excluded_users_dataset.empty?
        conditions << Sequel.~({ user: self.excluded_users_dataset })
      end
      if !self.terms_dataset.empty?
        self.terms.each do |term|
          conditions << { id: Annotation.select(:observation_id).where({ term_id: term.term_id, term_value_id: term.term_value_id }) }
        end
      end
      if !self.quality_grades_dataset.empty?
        conditions << { quality_grade: self.quality_grades_dataset.select(:quality_grade) }
      end
      return Sequel.&(*conditions)
    else
      return { project_id: self.id }
    end
  end

  # @return [Sequel::Dataset<INatGet::Data::Model::Observation>]
  def observations
    INatGet::Data::Model::Observation.where(self.to_sequel)
  end

  class << self

    def manager = INatGet::Data::Manager::Projects::instance

  end

end

# frozen_string_literal: true

require 'sequel'

require_relative '../info'
require_relative 'observation'
require_relative 'projectadmin'
require_relative 'projectqualitygrade'
require_relative 'projectterm'

module INatGet::Models; end

class INatGet::Models::Project < Sequel::Model(:projects)

  many_to_many :manual_observations, class: :'INatGet::Models::Observation', join_table: :observation_projects, left_key: :project_id, right_key: :observation_id

  many_to_many :included_taxa, class: :'INatGet::Models::Taxon', join_table: :project_included_taxa, left_key: :project_id, right_key: :taxon_id
  many_to_many :excluded_taxa, class: :'INatGet::Models::Taxon', join_table: :project_excluded_taxa, left_key: :project_id, right_key: :taxon_id
  many_to_many :included_places, class: :'INatGet::Models::Place', join_table: :project_included_places, left_key: :project_id, right_key: :place_id
  many_to_many :excluded_places, class: :'INatGet::Models::Place', join_table: :project_excluded_places, left_key: :project_id, right_key: :place_id
  many_to_many :included_users, class: :'INatGet::Models::User', join_table: :project_included_users, left_key: :project_id, right_key: :user_id
  many_to_many :excluded_users, class: :'INatGet::Models::User', join_table: :project_excluded_users, left_key: :project_id, right_key: :user_id

  many_to_many :subprojects, class: self, join_table: :umbrella_projects, left_key: :umbrella_id, right_key: :subproject_id

  many_to_many :members, class: :'INatGet::Models::User', join_table: :project_members, left_key: :project_id, right_key: :user_id

  one_to_many :admins, class: :'INatGet::Models::ProjectAdmin'
  one_to_many :quality_grades, :'INatGet::Models::ProjectQualityGrade'
  one_to_many :terms, :'INatGet::Models::ProjectTerm'

  def to_sequel
    if self.is_umbrella
      return Sequel.|(*self.subprojects.map(&:to_sequel))
    elsif self.is_collection
      conditions = []
      if !self.included_taxa.empty?
        conditions << Sequel.|(*self.included_taxa.map { |taxon| { taxon: taxon.descendants } })
      end
      if !self.excluded_taxa.empty?
        conditions << Sequel.~(Sequel.|(*self.excluded_taxa.map { |taxon| { taxon: taxon.descendants } }))
      end
      if !self.included_places.empty?
        conditions << { place: self.included_places }
      end
      if !self.excluded_places.empty?
        conditions << Sequel.~({ place: self.excluded_places })
      end
      if self.members_only
        conditions << { user: self.members }
      elsif !self.included_users.empty?
        conditions << { user: self.included_users }
      end
      if !self.excluded_users.empty?
        conditions << Sequel.~({ user: self.excluded_users })
      end
      # TODO: добавить Terms
      return Sequel.&(*conditions)
    else
      return { project_id: self.id }
    end
  end

  def observations
    INatGet::Models::Observation.where(self.to_sequel)
  end

end

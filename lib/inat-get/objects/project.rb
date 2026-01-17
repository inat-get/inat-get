# frozen_string_literal: true

require 'sequel'

require_relative '../info'
require_relative 'projectadmin'
require_relative 'projectqualitygrade'

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

end

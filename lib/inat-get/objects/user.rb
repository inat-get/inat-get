# frozen_string_literal: true

require 'sequel'

require_relative '../info'

module INatGet::Models; end

class INatGet::Models::User < Sequel::Model(:users)

  one_to_many :observations
  one_to_many :identifications
  one_to_many :faves, class: :'INatGet::Models::Fave'

  many_to_many :projects, class: :'INatGet::Models::Project', join_table: :project_members, left_key: :user_id, right_key: :project_id
  many_to_many :managed_projects, class: :'INatGet::Models::Project', join_table: :project_admins, left_key: :user_id, right_key: :project_id

end

# frozen_string_literal: true

require 'sequel'

require_relative '../info'
require_relative 'project'
require_relative 'place'
require_relative 'taxon'
require_relative 'user'

module INatGet::Models; end

class INatGet::Models::Request < Sequel::Model(:requests)

  many_to_many :projects, class: INatGet::Models::Project, join_table: :request_projects, left_key: :request_hash, right_key: :project_id
  many_to_many :places, class: INatGet::Models::Place, join_table: :request_places, left_key: :request_hash, right_key: :place_id
  many_to_many :taxa, class: INatGet::Models::Taxon, join_table: :request_taxa, left_key: :request_hash, right_key: :taxon_id
  many_to_many :users, class: INatGet::Models::User, join_table: :request_users, left_key: :request_hash, right_key: :user_id

end

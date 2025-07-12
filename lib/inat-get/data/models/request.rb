# frozen_string_literal: true

require 'json'
require 'digest'
require 'sequel'

require_relative '../../info'
require_relative 'project'
require_relative 'place'
require_relative 'taxon'
require_relative 'user'

class INatGet::Data::Model::Request < INatGet::Data::Model

  set_dataset :requests

  # unrestrict_primary_key
  # set_primary_key :hash

  many_to_many :projects, class: INatGet::Data::Model::Project, join_table: :request_projects, left_key: :request_hash, right_key: :project_id
  many_to_many :places,   class: INatGet::Data::Model::Place,   join_table: :request_places,   left_key: :request_hash, right_key: :place_id
  many_to_many :taxa,     class: INatGet::Data::Model::Taxon,   join_table: :request_taxa,     left_key: :request_hash, right_key: :taxon_id
  many_to_many :users,    class: INatGet::Data::Model::User,    join_table: :request_users,    left_key: :request_hash, right_key: :user_id

  mk_apks

end

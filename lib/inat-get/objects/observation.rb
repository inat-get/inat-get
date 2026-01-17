# frozen_string_literal: true

require 'sequel'

require_relative '../info'
require_relative 'fave'
require_relative 'photo'
require_relative 'sound'
require_relative 'place'
require_relative 'project'
require_relative 'tag'
require_relative 'taxon'
require_relative 'identification'
require_relative 'user'

module INatGet::Models; end

class INatGet::Models::Observation < Sequel::Model(:observations)

  one_to_many :faves, class: INatGet::Models::Fave
  one_to_many :tags, class: INatGet::Models::Tag
  one_to_many :identifications, class: INatGet::Models::Identification

  many_to_one :taxon, class: INatGet::Models::Taxon
  many_to_one :user, class: INatGet::Models::User
  
  many_to_many :photos, class: INatGet::Models::Photo, join_table: :observation_photos, left_key: :observation_id, right_key: :photo_id
  many_to_many :sounds, class: INatGet::Models::Sound, join_table: :observation_sounds, left_key: :observation_id, right_key: :sound_id
  many_to_many :places, class: INatGet::Models::Place, join_table: :observation_places, left_key: :observation_id, right_key: :place_id
  many_to_many :manual_projects, class: INatGet::Model::Project, join_table: :observation_projects, left_key: :observation_id, right_key: :project_id

end

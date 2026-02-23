# frozen_string_literal: true

require 'sequel'

require_relative '../../info'
require_relative 'fave'
require_relative 'photo'
require_relative 'sound'
require_relative 'place'
require_relative 'tag'
require_relative 'taxon'
require_relative 'identification'
require_relative 'user'
require_relative 'annotation'

module INatGet::Data; end

class INatGet::Data::Model::Observation < INatGet::Data::Model

  set_dataset :observations

  one_to_many :faves,           class: INatGet::Data::Model::Fave
  one_to_many :tags,            class: INatGet::Data::Model::Tag
  one_to_many :identifications, class: INatGet::Data::Model::Identification
  one_to_many :annotations,     class: INatGet::Data::Model::Annotation

  many_to_one :taxon, class: INatGet::Data::Model::Taxon
  many_to_one :user,  class: INatGet::Data::Model::User
  
  many_to_many :photos, class: INatGet::Data::Model::Photo, join_table: :observation_photos, left_key: :observation_id, right_key: :photo_id
  many_to_many :sounds, class: INatGet::Data::Model::Sound, join_table: :observation_sounds, left_key: :observation_id, right_key: :sound_id
  many_to_many :places, class: INatGet::Data::Model::Place, join_table: :observation_places, left_key: :observation_id, right_key: :place_id
  many_to_many :manual_projects, class: :'INatGet::Data::Model::Project', join_table: :observation_projects, left_key: :observation_id, right_key: :project_id

  def photo_licenses
    photos.map(&:license)
  end

  def sound_licenses
    sounds.map(&:license)
  end

  def tag_values
    tags.map(&:tag)
  end

  class << self

    def manager = INatGet::Data::Manager::Observations::instance

  end

end

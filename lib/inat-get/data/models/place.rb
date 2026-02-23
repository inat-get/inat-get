# frozen_string_literal: true

require 'sequel'

require_relative '../../info'

module INatGet::Data; end

class INatGet::Data::Model::Place < INatGet::Data::Model

  set_dataset :places

  many_to_many :observations, class: :'INatGet::Data::Model::Observation', join_table: :observation_places, left_key: :place_id, right_key: :observation_id
  
  many_to_many :ancestors, class: self, join_table: :place_ancestors, left_key: :place_id, right_key: :ancestor_id
  many_to_many :descendants, class: self, join_table: :place_ancestors, left_key: :ancestor_id, right_key: :place_id

  many_to_many :projects, class: :'INatGet::Data::Model::Project', join_table: :project_included_places, left_key: :place_id, right_key: :project_id

  class << self

    # @return [Manager::Places]
    def manager = INatGet::Data::Manager::Places::instance

  end

  mk_apks

end

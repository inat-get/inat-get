# frozen_string_literal: true

require "sequel"

require_relative "../../info"

class INatGet::Data::Model::Tag < INatGet::Data::Model

  set_dataset :observation_tags

  many_to_one :observation, class: :'INatGet::Data::Model::Observation'

  include INatGet::Data::Model::Sub

  def owner = self.observation

  class << self

    def inner_key() = :tags
    
  end

end

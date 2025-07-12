# frozen_string_literal: true

require 'sequel'

require_relative '../../info'
require_relative 'base'

module INatGet::Data; end

class INatGet::Data::Model::Identification < INatGet::Data::Model

  set_dataset :identifications

  many_to_one :observation, class: :'INatGet::Data::Model::Observation'
  many_to_one :taxon, class: :'INatGet::Data::Model::Taxon'
  many_to_one :user, class: :'INatGet::Data::Model::User'

  include INatGet::Data::Model::Sub

  def owner = self.observation

  class << self

    def manager = INatGet::Data::Manager::Identifications::instance

  end

end

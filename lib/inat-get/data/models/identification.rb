# frozen_string_literal: true

require "sequel"

require_relative "../../info"

module INatGet::Data; end
module INatGet::Data::Model; end

class INatGet::Data::Model::Identification < Sequel::Model

  set_dataset :identifications

  many_to_one :observation, class: :'INatGet::Data::Model::Observation'
  many_to_one :taxon, class: :'INatGet::Data::Model::Taxon'
  many_to_one :user, class: :'INatGet::Data::Model::User'

end

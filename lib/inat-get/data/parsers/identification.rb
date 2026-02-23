# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Identification < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :observation_id => :owner_id
  part Part::Copy, :body, :category, :current, :disagreement, :hidden, :own_observation, :vision, :uuid
  part Part::DateTime, :created => :created_at
  part Part::Model, :taxon, model: INatGet::Data::Model::Taxon
  part Part::Model, :user,  model: INatGet::Data::Model::User
  part Part::Cached

  # @return [Model::Identification]
  def model = INatGet::Data::Model::Identification

end
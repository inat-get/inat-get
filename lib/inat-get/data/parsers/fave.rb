# frozen_string_literal: true

require 'singleton'

require_relative 'base'
require_relative 'defs/pk'
require_relative 'defs/time'
require_relative 'defs/model'
require_relative '../models/user'

class INatGet::Data::Parser::Fave < INatGet::Data::Parser

  include Singleton

  part Part::PK, :observation_id => :owner_id
  part Part::Time, :created => :created_at
  part Part::Model, :user, model: INatGet::Data::Model::User

  # @return [class Model::Fave]
  def model = INatGet::Data::Model::Fave

end

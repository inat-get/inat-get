# frozen_string_literal: true

require 'singleton'

require_relative 'base'
require_relative 'defs/pk'
require_relative 'defs/copy'
require_relative 'defs/model'

class INatGet::Data::Parser::Annotation < INatGet::Data::Parser

  include Singleton

  part Part::PK, :observation_id => :owner_id, :term_id => :controlled_attribute_id, :term_value_id => :controlled_value_id
  part Part::Copy, :uuid, :vote_score
  part Part::Model, :user, model: INatGet::Data::Model::User

  # @return [class Model::Annotation]
  def model = INatGet::Data::Model::Annotation

end

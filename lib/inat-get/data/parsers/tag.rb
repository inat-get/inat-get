# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Tag < INatGet::Data::Parser

  include Singleton

  part Part::PK, :observation_id => :owner_id, :tag => :value

  # @return [class Model::Annotation]
  def model = INatGet::Data::Model::Tag

end

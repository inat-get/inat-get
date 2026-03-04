# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Tag < INatGet::Data::Parser

  include Singleton

  part Part::PK, :observation_id => :owner_id, :tag => :value

  # @private
  def inner_key() = :tags

end

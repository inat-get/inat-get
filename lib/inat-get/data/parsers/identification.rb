# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Identification < INatGet::Data::Parser

  include Singleton

  # @return [Model::Identification]
  def model = INatGet::Data::Model::Identification

end

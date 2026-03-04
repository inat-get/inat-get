# frozen_string_literal: true

require_relative 'base'
require_relative 'defs'
require_relative 'defs/pk'
require_relative 'defs/copy'

class INatGet::Data::Parser::Photo < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :url, :license => :license_code

  # def model() = INatGet::Data::Model::Photo

  # @private
  def inner_key() = :photos

  def fake id
    self.model.create id: id, url: ''
  end

end

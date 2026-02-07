# frozen_string_literal: true

require 'singleton'

require_relative 'main'

class INatGet::Data::Parser::Identification < INatGet::Data::Parser

  include Singleton

  def entry!(src) = self.identification!(src)

end

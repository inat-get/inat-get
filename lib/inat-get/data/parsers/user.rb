# frozen_string_literal: true

require 'singleton'

require_relative 'main'

class INatGet::Data::Parser::User < INatGet::Data::Parser

  include Singleton

  def entry!(src) = self.user!(src)

end

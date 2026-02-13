# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Helper::Users < INatGet::Data::Helper

  include Singleton

  # @return [INatGet::Data::Manager::Users]
  def manager() = INatGet::Data::Manager::Users::instance

end

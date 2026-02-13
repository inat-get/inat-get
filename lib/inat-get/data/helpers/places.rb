# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Helper::Places < INatGet::Data::Helper

  include Singleton

  # @return [INatGet::Data::Manager::Places]
  def manager() = INatGet::Data::Manager::Places::instance

end

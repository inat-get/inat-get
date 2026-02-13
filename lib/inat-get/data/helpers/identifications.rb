# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Helper::Identifications < INatGet::Data::Helper

  include Singleton

  # @return [INatGet::Data::Manager::Identifications]
  def manager() = INatGet::Data::Manager::Identifications::instance

end

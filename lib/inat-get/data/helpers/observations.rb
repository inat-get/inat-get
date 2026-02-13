# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Helper::Observations < INatGet::Data::Helper

  include Singleton

  # @return [INatGet::Data::Manager::Observations]
  def manager() = INatGet::Data::Manager::Observations::instance

end

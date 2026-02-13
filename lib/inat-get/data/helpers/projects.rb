# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Helper::Projects < INatGet::Data::Helper

  include Singleton

  # @return [INatGet::Data::Manager::Projects]
  def manager() = INatGet::Data::Manager::Projects::instance

end

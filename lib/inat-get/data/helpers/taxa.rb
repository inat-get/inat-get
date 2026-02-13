# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Helper::Taxa < INatGet::Data::Helper

  include Singleton

  # @return [INatGet::Data::Manager::Taxa]
  def manager() = INatGet::Data::Manager::Taxa::instance
  
end


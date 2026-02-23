# frozen_string_literal: true

require 'singleton'

require_relative 'base'

# @todo Must be implemented before v1.0
class INatGet::Data::Helper::Identifications < INatGet::Data::Helper

  include Singleton

  # TODO: fields, Must be implemented before v1.0

  # @return [INatGet::Data::Manager::Identifications]
  def manager() = INatGet::Data::Manager::Identifications::instance

end

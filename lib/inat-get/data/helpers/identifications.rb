# frozen_string_literal: true

require 'singleton'

require_relative 'base'

# @todo Must be implemented before v1.0
class INatGet::Data::Helper::Identifications < INatGet::Data::Helper

  include Singleton

  def endpoint() = :identifications

  # TODO: fields, Must be implemented before v1.0

end

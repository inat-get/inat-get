# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Users < INatGet::Data::Updater

  include Singleton

  # @return [:users]
  def endpoint() = :users

  # @return [Integer]
  def slice_size() = 1

end

# @private
class INatGet::Data::Updater::ProjectUsers < INatGet::Data::Updater::Users

  include Singleton

  def slice_size() = 200

end

# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Updater::Users < INatGet::Data::Updater

  include Singleton

  # @return [INatGet::Data::Manager::Users]
  def manager() = INatGet::Data::Manager::Users::instance

  # def update_by_ids! *ids
  #   pp({INPUT: ids})
  #   result = super(*ids)
  #   pp({RESULT: result})
  #   result
  # end

  def slice_size = 1

end

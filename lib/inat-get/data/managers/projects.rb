# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Manager::Projects < INatGet::Data::Manager::Base

  include Singleton

  # @return [:projects]
  def entrypoint = :projects

  # @return [INatGet::Data::Model::Project]
  def model = INatGet::Data::Model::Project

  # @return [:slug]
  def sid = :slug

  def updater = nil # FIXME
    
end


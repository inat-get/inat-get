# frozen_string_literal: true

require 'sequel'

require_relative '../../info'
require_relative 'base'

class INatGet::Data::Model::User < INatGet::Data::Model

  set_dataset :users

  one_to_many :observations
  one_to_many :identifications
  one_to_many :faves, class: :'INatGet::Data::Model::Fave'

  many_to_many :projects, class: :'INatGet::Data::Model::Project', join_table: :project_members, left_key: :user_id, right_key: :project_id
  many_to_many :managed_projects, class: :'INatGet::Data::Model::Project', join_table: :project_admins, left_key: :user_id, right_key: :project_id

  class << self

    def manager = INatGet::Data::Manager::Users::instance

  end

  include Comparable

  def <=> other
    return nil unless other.is_a?(INatGet::Data::Model::User)
    return 0 if self.id == other.id
    self.login <=> other.login
  end

end

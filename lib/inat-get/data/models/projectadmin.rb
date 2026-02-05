# frozen_string_literal: true

require 'sequel'

require_relative "../../info"

module INatGet::Data; end
module INatGet::Data::Model; end

class INatGet::Data::Model::ProjectAdmin < Sequel::Model

  set_dataset :project_admins

  many_to_one :project
  many_to_one :user

end

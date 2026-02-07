# frozen_string_literal: true

require 'sequel'

require_relative '../../info'

module INatGet::Data; end
module INatGet::Data::Model; end

class INatGet::Data::Model::Annotation < Sequel::Model

  set_dataset :annotations

  many_to_one :observation, class: :'INatGet::Data::Model::Observation'
  many_to_one :user, class: :'INatGet::Data::Model::User'

  include INatGet::Data::Model::Sub

  # @group Structure

  # @return [INatGet::Data::Model::Observation]
  def owner = self.observation

end

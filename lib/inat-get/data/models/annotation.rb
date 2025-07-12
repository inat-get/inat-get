# frozen_string_literal: true

require 'sequel'

require_relative '../../info'
require_relative '../parsers/annotation'

class INatGet::Data::Model::Annotation < INatGet::Data::Model

  set_dataset :annotations

  many_to_one :observation, class: :'INatGet::Data::Model::Observation'
  many_to_one :user, class: :'INatGet::Data::Model::User'

  include INatGet::Data::Model::Sub

  # @group Structure

  # @return [INatGet::Data::Model::Observation]
  def owner = self.observation

  # @endgroup

  class << self

    # @return [Parser::Annotation]
    def parser = INatGet::Data::Parser::Annotation::instance

  end

end

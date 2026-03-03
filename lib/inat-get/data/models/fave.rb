# frozen_string_literal: true

require 'sequel'

require_relative '../../info'
require_relative 'base'
require_relative 'sub'
# require_relative '../parsers/fave'

module INatGet::Data; end

class INatGet::Data::Model::Fave < INatGet::Data::Model

  set_dataset :observation_faves

  many_to_one :observation
  many_to_one :user

  include INatGet::Data::Model::Sub

  def owner = self.observation

  class << self

    private def inner_key() = :faves

  end

end

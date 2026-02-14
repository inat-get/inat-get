# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Helper::Projects < INatGet::Data::Helper

  include Singleton

  field :id,        INatGet::Data::Helper::Field::Ids
  field :slug,      INatGet::Data::Helper::Field::Ids
  field :type,      INatGet::Data::Helper::Field::Set, String
  field :place,     INatGet::Data::Helper::Field::Models, INatGet::Data::Model::Place
  field :latitude,  INatGet::Data::Helper::Field::ScalarCoord
  field :longitude, INatGet::Data::Helper::Field::ScalarCoord
  field :radius,    INatGet::Data::Helper::Field::Scalar, Float
  field :location,  INatGet::Data::Helper::Field::ScalarLocation

  # @return [INatGet::Data::Manager::Projects]
  def manager() = INatGet::Data::Manager::Projects::instance

end

# frozen_string_literal: true

require 'singleton'
require 'is-boolean'

require_relative 'base'
require_relative 'defs/ids'

class INatGet::Data::Helper::Observations < INatGet::Data::Helper

  include Singleton

  field :id,             INatGet::Data::Helper::Field::Ids
  field :captive,        INatGet::Data::Helper::Field::Scalar, Boolean
  field :endemic,        INatGet::Data::Helper::Field::Scalar, Boolean
  field :identified,     INatGet::Data::Helper::Field::Scalar, Boolean
  field :introduced,     INatGet::Data::Helper::Field::Scalar, Boolean
  field :native,         INatGet::Data::Helper::Field::Scalar, Boolean
  field :out_of_range,   INatGet::Data::Helper::Field::Scalar, Boolean
  field :popular,        INatGet::Data::Helper::Field::Scalar, Boolean
  field :photos,         INatGet::Data::Helper::Field::Scalar, Boolean
  field :sounds,         INatGet::Data::Helper::Field::Scalar, Boolean
  field :threatened,     INatGet::Data::Helper::Field::Scalar, Boolean
  field :verifiable,     INatGet::Data::Helper::Field::Scalar, Boolean
  field :licensed,       INatGet::Data::Helper::Field::Scalar, Boolean
  field :photo_licensed, INatGet::Data::Helper::Field::Scalar, Boolean
  field :sound_licensed, INatGet::Data::Helper::Field::Scalar, Boolean
  field :license,        INatGet::Data::Helper::Field::Set,    String
  field :photo_license,  INatGet::Data::Helper::Field::Set,    String
  field :sound_license,  INatGet::Data::Helper::Field::Set,    String
  field :place,          INatGet::Data::Helper::Field::Models, INatGet::Data::Model::Place
  field :user,           INatGet::Data::Helper::Field::Models, INatGet::Data::Model::User
  field :project,        INatGet::Data::Helper::Field::Project
  field :taxon,          INatGet::Data::Helper::Field::Taxon
  field :rank,           INatGet::Data::Helper::Field::Rank
  field :observed_year,  INatGet::Data::Helper::Field::DatePart
  field :observed_month, INatGet::Data::Helper::Field::DatePart
  field :observed_week,  INatGet::Data::Helper::Field::DatePart, true
  field :observed_day,   INatGet::Data::Helper::Field::DatePart
  field :observed_hour,  INatGet::Data::Helper::Field::DatePart
  field :created_year,   INatGet::Data::Helper::Field::DatePart
  field :created_month,  INatGet::Data::Helper::Field::DatePart
  field :created_week,   INatGet::Data::Helper::Field::DatePart, true
  field :created_day,    INatGet::Data::Helper::Field::DatePart
  field :created_hour,   INatGet::Data::Helper::Field::DatePart, true
  # TODO: all other

  # @return [INatGet::Data::Manager::Observations]
  def manager() = INatGet::Data::Manager::Observations::instance

end

# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::Observation < INatGet::Data::Parser

  include Singleton

  part INatGet::Data::Parser::Part::Scalar, :captive, :mappable, :obscured
  part INatGet::Data::Parser::Part::Scalar, :description, :uuid
  part INatGet::Data::Parser::Part::Scalar, :observed_time_zone => :observed_timezone, :created_time_zone => :created_timezone
  part INatGet::Data::Parser::Part::Time, :created_at => :created, :time_observed_at => :observed, :updated_at => :updated
  part INatGet::Data::Parser::Part::TimeDetails, :created_at_details => :created, :observed_on_details => :observed
  part INatGet::Data::Parser::Part::Scalar, :geoprivacy, :taxon_geoprivacy, :quality_grade, :license_code => :license
  part INatGet::Data::Parser::Part::Location
  part INatGet::Data::Parser::Part::Model, INatGet::Data::Parser::Taxon::instance, :taxon
  part INatGet::Data::Parser::Part::Model, INatGet::Data::Parser::User::instance, :user
  part INatGet::Data::Parser::Part::Save
  part INatGet::Data::Parser::Part::Subs, INatGet::Data::Parser::Identification::instance, :identifications
  part INatGet::Data::Parser::Part::Subs, INatGet::Data::Parser::Annotation::instance, :annotations
  part INatGet::Data::Parser::Part::Subs, INatGet::Data::Parser::Tag::instance, :tags
  part INatGet::Data::Parser::Part::Subs, INatGet::Data::Parser::Fave::instance, :faves
  part INatGet::Data::Parser::Part::Links, INatGet::Data::Parser::Photo::instance, :photos
  part INatGet::Data::Parser::Part::Links, INatGet::Data::Parser::Sound::instance, :sounds
  part INatGet::Data::Parser::Part::Links, INatGet::Data::Parser::Place::instance, :places, ids: :place_ids
  part INatGet::Data::Parser::Part::Links, INatGet::Data::Parser::Project::instance, :manual_projects, ids: :project_ids

  # @return [class Model::Observation]
  def model = INatGet::Data::Model::Observation

end

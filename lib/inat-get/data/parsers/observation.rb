# frozen_string_literal: true

require 'date'
require 'singleton'

require_relative 'base'
require_relative 'defs/pk'
require_relative 'defs/copy'
require_relative 'defs/time'
require_relative 'defs/details'
require_relative 'defs/location'
require_relative 'defs/model'
require_relative 'defs/cached'
require_relative 'defs/children'
require_relative 'defs/links'

class INatGet::Data::Parser::Observation < INatGet::Data::Parser

  include Singleton

  part Part::PK          # :id => :id
  part Part::Copy, :captive, :mappable, :obscured, :description, :uuid, :geoprivacy, :taxon_geoprivacy, :quality_grade
  part Part::Copy, :license => :license_code, :observed_timezone => :observed_time_zone, :created_timezone => :created_time_zone
  part Part::DateTime, :created => :created_at, :observed => :time_observed_at, :updated => :updated_at
  part Part::Details, :created => :created_at_details, :observed => :observed_on_details
  part Part::Location
  part Part::Model, :user,  model: INatGet::Data::Model::User
  part Part::Cached

  part Part::Children, :identifications, model: INatGet::Data::Model::Identification
  part Part::Children, :annotations,     model: INatGet::Data::Model::Annotation
  part Part::Children, :faves,           model: INatGet::Data::Model::Fave
  part Part::Children, :tags,            model: INatGet::Data::Model::Tag

  part Part::AssModel, :taxon, model: INatGet::Data::Model::Taxon

  part Part::Links, :photos,          model: INatGet::Data::Model::Photo
  part Part::Links, :sounds,          model: INatGet::Data::Model::Sound
  part Part::Links, :places,          model: INatGet::Data::Model::Place
  part Part::Links, :manual_projects, model: INatGet::Data::Model::Project, source_ids: :project_ids

  # @return [class Model::Observation]
  def model = INatGet::Data::Model::Observation

  def fake id
    now = DateTime::now
    self.model.create id: id, created: now, observed: now, updated: now, cached: now, quality_grade: 'fake', user: INatGet::Data::Manager::Users::instance.get(0),
                      created_year: now.year, created_month: now.month, created_week: now.to_date.cweek, created_day: now.day, created_hour: now.hour
  end

end

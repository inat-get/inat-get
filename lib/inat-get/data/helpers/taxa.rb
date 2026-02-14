# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Helper::Taxa < INatGet::Data::Helper

  include Singleton

  field :id,        INatGet::Data::Helper::Field::Ids
  field :is_active, INatGet::Data::Helper::Field::Scalar, Boolean
  field :rank,      INatGet::Data::Helper::Field::Rank
  field :parent,    INatGet::Data::Helper::Field::ScalarModel, INatGet::Data::Model::Taxon

  # @return [INatGet::Data::Manager::Taxa]
  def manager() = INatGet::Data::Manager::Taxa::instance
  
end

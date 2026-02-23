# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::User < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :login, :name, :orcid, :suspended
  part Part::DateTime, :created => :created_at
  part Part::Cached

  def model() = INatGet::Data::Model::User

  def fake id
    self.model.create id: id, login: "fake#{ id }", name: "Fake user \##{ id }", suspended: false, created: DateTime::now, cached: DateTime::now
  end

end

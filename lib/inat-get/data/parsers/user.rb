# frozen_string_literal: true

require 'singleton'

require_relative 'base'

class INatGet::Data::Parser::User < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :login, :name, :orcid, :suspended
  part Part::Time, :created => :created_at
  part Part::Cached

  def manager() = INatGet::Data::Manager::Users::instance

  def fake id
    self.model.create id: id, login: "fake#{ id }", name: "Fake user \##{ id }", suspended: false, created: Time::now, cached: Time::now
  end

end

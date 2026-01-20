# frozen_string_literal: true

require 'singleton'

require_relative '../info'

module INatGet::Data; end

module INatGet::Data::Parser; end

module INatGet::Data::Parser::Common

  def parse! source
    self.model.db.transaction do
      if source.is_a?(Enumerable)
        source.map { |src| parse_entity!(src) }
      else
        parse_entity!(source)
      end
    end
  end

end

class INatGet::Data::Parser::Project

  include Singleton
  include INatGet::Data::Parser::Common

  def model
    INatGet::Models::Project
  end

  def parse_entity! source
    # TODO: implement
  end

  def fake id
    now = Time.now
    rec = INatGet::Models::Project::create id: id, 
                                         slug: "#{ Random.alphanumeric }-#{ id }",
                                        title: "Ghost project \##{ id }", 
                                      created: now, 
                                      updated: now, 
                                  is_umbrella: false,
                                is_collection: false,
                                 members_only: false
    rec.save
  end

end

class INatGet::Data::Parser::Place

  include Singleton
  include INatGet::Data::Parser::Common

  def model
    INatGet::Models::Place
  end

  def parse_entity! source
    # TODO: implement
  end

  def fake id
    rec = INatGet::Models::Place::create id: id,
                                       slug: "#{ Random.alphanumeric }-#{ id }",  
                                       name: "Ghost place \##{ id }",
                               display_name: "Ghost place \##{ id }"
    rec.save
  end

end

class INatGet::Data::Parser::Taxon

  include Singleton
  include INatGet::Data::Parser::Common

  def model
    INatGet::Models::Taxon
  end

  def parse_entity! source
    # TODO: implement
  end

  def fake id
    rec = INatGet::Models::Taxon::create id: id,
                                       name: "Ghost taxon \##{ id }",
                                  is_active: false
    rec.save
  end

end

class INatGet::Data::Parser::User

  include Singleton
  include INatGet::Data::Parser::Common

  def model
    INatGet::Models::User
  end

  def parse_entity! source
    # TODO: implement
  end

  def fake id
    now = Time.now
    rec = INatGet::Models::User::create id: id,
                                     login: "#{ Random.alphanumeric }_#{ id }",
                                      name: "Ghost user \##{ id }",
                                   created: now,
                                 suspended: true
    rec.save
  end

end

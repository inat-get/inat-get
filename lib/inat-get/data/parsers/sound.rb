# frozen_string_literal: true

class INatGet::Data::Parser::Sound < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :url => :file_url, :license => :license_code

  # @private
  def inner_key() = :sounds

  def fake id
    self.model.create id: id, url: ''
  end

end

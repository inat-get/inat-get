# frozen_string_literal: true

class INatGet::Data::Parser::Sound < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :url => :file_url, :license => :license_code

  # @return [class Model::Sound]
  def model() = INatGet::Data::Model::Sound

  def fake id
    self.model.create id: id, url: ''
  end

end

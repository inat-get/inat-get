# frozen_string_literal: true

class INatGet::Data::Parser::Photo < INatGet::Data::Parser

  include Singleton

  part Part::PK
  part Part::Copy, :url, :license => :license_code

  # @return [class Model::Photo]
  def model() = INatGet::Data::Model::Photo

  def fake id
    self.model.create id: id, url: ''
  end

end

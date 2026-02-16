# frozen_string_literal: true

class INatGet::Data::Parser::Part::Save < INatGet::Data::Parser::Part

  def apply target, source
    target.save
  end

end

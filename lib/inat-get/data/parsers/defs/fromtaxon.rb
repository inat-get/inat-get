# frozen_string_literal: true

class INatGet::Data::Parser::Part::FromTaxon < INatGet::Data::Parser::Part::Copy

  def parse value
    taxon = value[:taxon]
    if taxon
      if @name == :introduced
        !taxon[:native]
      else
        super(taxon)
      end
    else
      {}
    end
  end

end

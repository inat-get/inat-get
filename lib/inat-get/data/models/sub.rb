# frozen_string_literal: true

require_relative '../../info'

module INatGet::Data; end
module INatGet::Data::Model; end

module INatGet::Data::Model::Sub

  def owner = raise NorImplementedError, "Not implemented method 'owner' in abstract module", caller_locations

end

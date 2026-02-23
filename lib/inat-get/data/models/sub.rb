# frozen_string_literal: true

require_relative '../../info'

# @private
module INatGet::Data::Model::Sub

  def owner = raise NotImplementedError, "Not implemented method 'owner' in abstract module", caller_locations

end

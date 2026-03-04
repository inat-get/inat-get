# frozen_string_literal: true

require_relative '../../info'
require_relative '../../utils/simple_singular'

# @api private
class INatGet::Data::Parser

  # @group Parsing

  # @return [Array<Model>, Model]
  def parse! source
    case source
    when Array
      source.map { |s| entry!(s) }
    else
      entry! source
    end
  end

  # @return [Model]
  def fake(id) = raise NotImplementedError, "Not implemented method 'fake' for abstract class", caller_locations

  # @endgroup

  # @group Descendant Definitions

  # @return [Manager]
  def manager() = self.model.manager

  # @return [class of Model]
  def model()
    @model ||= get_model
  end

  # @private
  private def get_model
    name = inner_key.to_s.singular
    require_relative "../models/#{ name }"
    INatGet::Data::Model.const_get name.capitalize
  end

  private 
  
  # @private
  def inner_key() = raise NotImplementedError, "Not implemented method 'inner_key' for abstract Parser", caller_locations

  # @endgroup

end

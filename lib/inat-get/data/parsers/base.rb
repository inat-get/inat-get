# frozen_string_literal: true

require_relative '../../info'

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

  # # @return [Model]
  # def entry!(data) = raise NotImplementedError, "Not implemented method 'entry!' of abstract class", caller_locations

  # @return [Model]
  def fake(id) = raise NotImplementedError, "Not implemented method 'fake' for abstract class", caller_locations

  # @endgroup

  # @group Descendant Definitions

  # @return [Manager]
  def manager() = self.model.manager

  # @return [class of Model]
  def model() = raise NotImplementedError, "Not implemented method 'model' for abstract class", caller_locations

  # @endgroup

end

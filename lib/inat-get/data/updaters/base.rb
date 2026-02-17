# frozen_string_literal: true

require_relative '../../info'

# @api private
class INatGet::Data::Updater

  # @overload update! condition
  #   @param [INatGet::Data::DSL::Condition] conditions
  # @overload update! *ids
  #   @param [Array<Integer, String>] ids
  # @return [void]
  def update! *args
    if args.size == 1 && args.first.is_a?(INatGet::Data::DSL::Condition)
      update_by_condition! arg.first
    else
      update_by_ids!(*args)
    end
  end

  # @return [INatGet::Data::Parser]
  def parser() = raise NotImplementedError, "Not implemented method 'parser' for abstract class", caller_locations

  private

  def update_by_condition! condition
    # TODO:
  end

  def update_by_ids! *ids
    # TODO:
  end

end

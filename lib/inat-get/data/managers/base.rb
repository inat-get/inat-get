# frozen_string_literal: true

require 'singleton'

require_relative '../../info'

module INatGet::Data; end

# @api private
class INatGet::Data::Manager

  # @group Common Methods

  # Returns model instance, array of them or dataset.
  # @see #model
  # @return [Dataset::Model, Array<Sequel::Model> or INatGet::Data::DSL::Dataset]
  # @overload get id
  #   @param [Integer, String or Symbol] id
  #   @return [Sequel::Model]
  # @overload get *ids
  #   @param [Array<Integer, String or Symbol>] ids
  #   @return [Array<Sequel::Model>]
  # @overload get **query
  #   @param [Hash] query
  #   @return [INatGet::Data::DSL::Dataset]
  # @overload get condition
  #   @param [INatGet::Data::DSL::Condition] condition
  #   @return [INatGet::Data::DSL::Dataset]
  def get *args, **kwargs
    # TODO: implement
  end

  # @return [Sequel::Model, nil]
  def [] id
    # TODO: implement
  end

  # @return [Sequel::Model]
  def fake **data
    self.parser.fake data
  end

  # Update specified records.
  # @see #updater
  # @return [void]
  # @overload update id
  #   @param [Integer, String or Symbol] id
  # @overload update *ids
  #   @param [Array<Integer, String or Symbol>] ids
  # @overload update **query
  #   @param [Hash] query
  # @overload update condition
  #   @param [INatGet::Data::DSL::Condition] condition
  # @overload update object
  #   @param [Sequel::Model] object
  # @overload update *objects
  #   @param [Array<Sequel::Model>] objects
  def update *args, **kwargs
    # TODO: implement
  end

  # @endgroup

  # @group Descendant Specificators

  # @return [Symbol]
  def endpoint = raise NotImplementedError, "Not implemented 'endpoint' in abstract base class", caller_locations

  # @return [class of Sequel::Model]
  def model = raise NotImplementedError, "Not implemented 'model' is abstract base class", caller_locations

  # Name of `String` field that can be used as identifier or `nil`.
  # @return [Symbol, nil]
  def sid = nil

  # `true` if UUID supported.
  # @return [Boolean]
  def uuid? = false

  # @return [INatGet::Data::Updater]
  def updater = raise NotImplementedError, "Not implemented 'updater' is abstract base class", caller_locations

  # @return [INatGet::Data::Helper]
  def helper = raise NotImplementedError, "Not implemented 'helper' is abstract base class", caller_locations

  # @return [INatGet::Data::Parser]
  def parser = raise NotImplementedError, "Not implemented 'parser' is abstract base class", caller_locations

  # @endgroup

end

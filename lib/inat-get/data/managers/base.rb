# frozen_string_literal: true

require 'singleton'

require_relative '../../info'

module INatGet::Data; end

module INatGet::Data::Manager; end

class INatGet::Data::Manager::Base

  # @group Common Methods

  # Returns model instance, array of them or dataset.
  # @see #model
  # @return [Dataset::Model, Array<Sequel::Model> or INatGet::Dataset]
  # @overload get id
  #   @param [Integer, String or Symbol] id
  #   @return [Sequel::Model]
  # @overload get *ids
  #   @param [Array<Integer, String or Symbol>] ids
  #   @return [Array<Sequel::Model>]
  # @overload get **query
  #   @param [Hash] query
  #   @return [INatGet::Dataset]
  # @overload get condition
  #   @param [INatGet::Condition] condition
  #   @return [INatGet::Dataset]
  def get *args, **kwargs
    # TODO: implement
  end

  # @return [Sequel::Model, nil]
  def [] id
    # TODO: implement
  end

  # @return [Sequel::Model]
  def fake(id) = raise NorImplementedError, "Not implemented 'fake' is abstract base class", caller_locations

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
  #   @param [INatGet::Condition] condition
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
  def entrypoint = raise NorImplementedError, "Not implemented 'entrypoint' in abstract base class", caller_locations

  # @return [class of Sequel::Model]
  def model = raise NorImplementedError, "Not implemented 'model' is abstract base class", caller_locations

  # Name of `String` field that can be used as identifier or `nil`.
  # @return [Symbol, nil]
  def sid = nil

  # `true` if UUID supported.
  # @return [Boolean]
  def uuid? = false

  def updater = raise NorImplementedError, "Not implemented 'updater' is abstract base class", caller_locations

  # @endgroup

end

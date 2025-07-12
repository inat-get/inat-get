# frozen_string_literal: true

require 'singleton'

require_relative '../../info'
require_relative '../dsl/dataset'

module INatGet::Data; end

# @api private
class INatGet::Data::Manager

  # @group Common Methods

  # Returns model instance, array of them or dataset.
  # @see #model
  # @return [Enumerable<Model>, Model, nil]
  # @overload get *ids
  #   @param [Array<Integer, String>] ids
  #   @return [Array<Model>]
  # @overload get **query
  #   @param [Hash] query
  #   @return [DSL::Dataset]
  # @overload get condition
  #   @param [DSL::Condition] condition
  #   @return [DSL::Dataset]
  def get *args, **kwargs
    if kwargs.empty?
      if args.size == 1 
        arg = args.first
        if arg.is_a?(INatGet::Data::DSL::Condition)
          INatGet::Data::DSL::Dataset::new nil, arg
        else
          self.updater.update!(arg)
          Array(get_local_one arg)
        end
      else
        condition = INatGet::Data::DSL::Condition::Query[self.model, id: args]
        self.updater.update!(*args)
        args.map { |arg| get_local_one(arg) }
      end
    else
      raise ArgumentError, "Too many arguments", caller_locations unless args.empty?
      condition = INatGet::Data::DSL::Condition::Query[self.model, **kwargs]
      INatGet::Data::DSL::Dataset::new nil, condition
    end
  end

  # @private
  private def get_local_one id, no_fake = false
    if id.is_a?(Integer)
      result = self.model[id]
      result ||= self.parser.fake(id) unless no_fake
      result
    elsif id.is_a?(String)
      if self.uuid? && id =~ INatGet::Data::Helper::UUID_PATTERN
        self.model.where(uuid: id).first
      elsif self.sid
        self.model.where(self.sid.to_sym => id).first
      else
        raise ArgumentError, "Invalid id: #{ id.inspect }", caller_locations
      end
    else
      raise ArgumentError, "Invalid id: #{ id.inspect }", caller_locations
    end
  end

  # Return valid item or `nil`
  # @return [Model, nil]
  def [] id
    self.updater.update! id
    get_local_one id, true
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

# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Parser::Part 

  def initialize parser, *args, **kwargs
    @parser = parser
    @args = args
    @kwargs = kwargs
  end

  # @return [void]
  def apply(target, source) = raise NotImplementedError, "Not implemented method 'apply' for abstract class", caller_locations

end

class INatGet::Data::Parser

  class << self

    # @group Parts

    # @return [Array<Part>]
    def parts
      @parts ||= []
    end

    # @return [void]
    def part cls, *args, **kwargs
      @parts ||= []
      @parts << cls.new(self, *args, **kwargs)
    end

    # @endgroup

  end

  # @group Parts

  # @return [Array<Part>]
  def parts = self.class.parts

  # @endgroup

  # @group Parsing

  # @return [Model]
  def entry! source
    id = source[:id]
    raise ArgumentError, "Field 'id' not found in source", caller_locations unless id
    record = self.model[id]
    unless record
      record = self.model.new
      record.id = id
    end
    self.parts.each do |part|
      part.apply record, source
    end
    record.cached = Time::now
    record.save
    record
  end

  # @endgroup

end


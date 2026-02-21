# frozen_string_literal: true

require_relative 'base'

class INatGet::Data::Parser::Part 

  attr_reader :parser

  def initialize parser
    @parser = parser
  end

  # @return [Hash]
  def parse(source) = raise NotImplementedError, "Not implemented method 'parse' in abstract class", caller_locations

end

class INatGet::Data::Parser::Part::Assoc < INatGet::Data::Parser::Part

  def initialize parser, name, model:, source: nil, source_ids: nil
    super parser
    @name = name
    @model = model
    @source = source || @name
    @source_ids = source_ids || singular_ids(@source)
  end

  # @return [Hash, nil]
  def parse(target, source) = raise NotImplementedError, "Not implemented method 'parse' in abstract class", caller_locations

  private

  # @private
  def singular_ids name
    if name == :taxa
      :taxon_ids
    elsif name == :species
      :species_ids
    else
      str_name = name.to_s
      single = if str_name.end_with?('ies')
        str_name.sub(/ies$/, 'y')
      elsif str_name.end_with?('ses')
        str_name.sub(/ses$/, 's')
      elsif str_name.end_with?('xes')
        str_name.sub(/xes$/, 'x')
      elsif str_name.end_with?('shes')
        str_name.sub(/shes$/, 'sh')
      elsif str_name.end_with?('s') && !str_name.end_with?('ss')
        str_name.sub(/s$/, '')
      else
        str_name
      end
      "#{ single }_ids".to_sym
    end
  end

end

class INatGet::Data::Parser

  include INatGet::System::Context

  class << self

    # @group Parts

    # @return [Array<Part>]
    def parts
      @parts ||= []
    end

    private

    # @return [void]
    def part cls, *args, **kwargs
      @parts ||= []
      @parts << cls.new(self.instance, *args, **kwargs)
    end

    # @endgroup

  end

  # @group Parts

  # @return [Array<Part>]
  private def parts = self.class.parts

  # @endgroup

  # @group Parsing

  # @return [Model]
  def entry! source
    check_shutdown! { self.model.db.rollback_on_exit }
    fields = {}
    pk, rest = parts.partition { |p| p.is_a?(Part::PK) }
    pk.each do |a|
      result = a.parse source
      pp({ IN_ENTRY: { PK: result } })
      registered = result.delete :_registered
      return model.with_pk(registered.size == 1 ? registered.first : registered) if registered
      fields.merge! result
    end
    associations, attributes = rest.partition { |p| p.is_a?(Part::Assoc) }
    attributes.each do |a|
      pp({ IN_ENTRY: { ATTR: a.class.name } })
      fields.merge! a.parse(source)
    end
    # pp({ self.class => { UPSERT: fields } })
    record = upsert fields
    fields = {}
    associations.each do |a|
      pp({ IN_ENTRY: { ASSOC: a.class.name } })
      res = a.parse(record, source)
      fields.merge! res if res
    end
    # pp({ self.class => { UPDATE: fields } })
    record.update(fields) || record
  end

  # @endgroup

  private

  # @private

  def upsert data
    pk_cols = Array(model.primary_key)
    pk_vals = data.values_at(*pk_cols)
    record = if pk_vals.all?
      model.with_pk(pk_vals.size == 1 ? pk_vals.first : pk_vals)
    else
      raise ArgumentError, "Invalid PK for #{ model }: #{ pk_vals.inspect }", caller_locations
    end
    pp({ UPSERT: { MODEL: model, RECORD: record, PK: pk_vals, DATA: data.transform_values { |v| v.class } } })
    if record
      record.update(data) || record
    else
      model.create data
      # pp({ RESULT: r, EXISTS: r.exists?, ERRORS: r.errors }) if self.class == INatGet::Data::Parser::ProjectAdmin
      # r.save
    end
  end

end

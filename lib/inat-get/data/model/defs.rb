# frozen_string_literals: true

require 'set'

require_relative '../../utils/utils'
require_relative '../../core'
require_relative '../cached'
require_relative '../types'

class INatGet::Model < INatGet::Cached

  class Field
    attr_reader :model, :name, :rb_type, :json_field, :json_id_field

    # @api internal
    def initialize(model, name, rb_type, json_field, json_id_field)
      @model = model
      @name = name
      @rb_type = rb_type
      @json_field = json_field
      @json_id_field = json_id_field
    end
  end

  class ScalarField < Field
    attr_reader :length, :precision, :nulls

    # @api internal
    def initialize(model, name, rb_type, length, precision, json_field, nulls)
      super(model, name, rb_type, json_field, nil)
      @length = length
      @nulls = nulls
    end
  end

  class ModelField < Field
    attr_reader :nulls

    # @api internal
    def initialize(model, name, rb_type, json_field, json_id_field, nulls)
      super(model, name, rb_type, json_field, json_id_field)
      @nulls = nulls
    end
  end

  class CollectionField < Field
  end

  class LinksField < CollectionField
    attr_reader :link_table, :back_field, :link_field

    # @api internal
    def initialize(model, name, rb_type, json_field, json_id_field, link_table, back_field, link_field)
      super(model, name, rb_type, json_field, json_id_field)
      @link_table = link_table
      @back_fields = back_field
      @link_fields = link_field
    end
  end

  class BacksField < CollectionField
    attr_reader :back_field, :owned

    # @api internal
    def initialize(model, name, rb_type, json_field, json_id_field, back_field, owned)
      super(model, name, rb_type, json_field, json_id_field)
      @back_field = back_field
      @owned = owned
    end
  end

  class CustomField < Field
    attr_reader :parser, :getter

    def initialize(model, name, json_field, parser, getter)
      super(model, name, nil, json_field, nil)
      @parser = parser
      @getter = getter
    end
  end

  class Index
    attr_reader :model, :name, :fields

    # @api internal
    def initialize model, name, fields
      @model = model
      @name = name
      @fields = fields
    end
  end

  class Unique < Index
  end

  class PrimaryKey < Unique
  end

  class Reference
    attr_reader :model, :name, :field, :target

    # @api internal
    def initialize model, name, field, target
      @model = model
      @name = name
      @field = field
      @target = target
    end
  end

  # private_const :Field, :ScalarField, :ModelField, :CollectionField, :LinksField, :BacksField, :Index, :Unique, :PrimaryKey, :Reference

  class << self

    # @!group Metadata Definition

    # @api internal
    def define_scalar_field_accessors field
      fld = field
      var = "@#{ fld.name }".intern
      define_method fld.name do
        instance_variable_get(var)
      end
      define_method "#{ fld.name }=".intern do |value|
        raise ArgumentError, "Field #{ fld.name } must be not null", caller if value == nil && !fld.nulls
        raise ArgumentError, "Field #{ fld.name } must be a #{ fld.type }", caller unless fld.type === value
        instance_variable_set(var, value)
        @modified ||= Set::new
        @modified << fld.name
        value
      end
    end

    # @api internal
    def define_model_field_accessors field
      define_scalar_field_accessors field
      fld = field
      var = "@#{ fld.name }".intern
      define_method "#{ fld.name }_id".intern do
        instance_variable_get(var)&.key
      end
      define_method "#{ fld.name }_id=".intern do |key|
        raise ArgumentError, "Field #{ fld.name } must be not null", caller if key == nil && !fld.nulls
        value = key ? fld.type.get(key) : nil
        instance_variable_set(var, value)
        # TODO: update back fields referenced to this
        @modified ||= Set::new
        @modified << fld.name
        key
      end
    end

    # @api internal
    def define_model_reference field
      name = "fk_#{ self.short_name }_#{ field.name }".intern
      @references ||= {}
      @references[name] = Reference::new(self, name, field, field.type)
    end

    # @api DSL
    def field name, type, length: nil, precision: nil, json: nil, json_id: nil, nulls: true
      raise ArgumentError, "Invalid field's name: #{ name.inspect }", caller unless String === name || Symbol === name
      raise ArgumentError, "Invalid field's type: #{ type.inspect }", caller unless Module === type
      raise ArgumentError, "Invalid field's length: #{ length.inspect }", caller unless Integer === length || length == nil
      raise ArgumentError, "Invalid field's precision: #{ precision.inspect }", caller unless Integer === precision || precision == nil
      raise ArgumentError, "Invalid 'json' option: #{ json.inspect }", caller unless String === json || Symbol === json || json == nil || json == false
      raise ArgumentError, "Invalid 'json_id' option: #{ json_id.inspect }", caller unless String === json_id || Symbol === json_id || json_id == nil || json_id == false
      raise ArgumentError, "Invalid 'nulls' option: #{ nulls.inspect }", caller unless nulls == true || nulls == false || nulls == nil
      f_name = name.intern
      f_type = type
      f_json = json == false ? false : json&.intern || f_name
      f_nulls = nulls == false ? false : true      # Что не запрещено, то разрешено
      @fields ||= {}
      @fields[f_name] = if Class === type && type <= INatGet::Model
        f_json_id = json_id == false ? false : json_id&.intern || "#{ f_json }_id".intern
        fld = ModelField::new(self, f_name, f_type, f_json, f_json_id, f_nulls)
        define_model_field_accessors fld
        define_model_reference fld
        fld
      else
        fld = ScalarField::new(self, f_name, f_type, length, precision, f_json, f_nulls)
        define_scalar_field_accessors fld
        fld
      end
    end

    # @api internal
    def register_link_table field
      @@link_tables ||= {}
      @@link_tables[field.link_table] ||= []
      @@link_tables[field.link_table].delete_if { |fld| fld.model == field.model && fld.name == field.name }
      @@link_tables[field.link_table] << field
    end

    # @api internal
    def define_links_field_methods field
      # TODO: implement
    end

    # @api DSL
    def links name, type, json: nil, json_ids: nil, link_table: nil, back_field: nil, link_field: nil
      raise ArgumentError, "Invalid field's name: #{ name.inspect }", caller unless String === name || Symbol === name
      raise ArgumentError, "Invalid field's type: #{ type.inspect }", caller unless Module === type
      raise ArgumentError, "Invalid 'json' option: #{ json.inspect }", caller unless String === json || Symbol === json || json == nil || json == false
      raise ArgumentError, "Invalid 'json_ids' option: #{ json_ids.inspect }", caller unless String === json_ids || Symbol === json_ids || json_ids == nil || json_ids == false
      raise ArgumentError, "Invalid 'link_table' option: #{ link_table.inspect }", caller unless String === link_table || Symbol === link_table || link_table == nil
      raise ArgumentError, "Invalid 'back_field' option: #{ back_field.inspect }", caller unless String === back_field || Symbol === back_field || back_field == nil
      raise ArgumentError, "Invalid 'link_field' option: #{ link_field.inspect }", caller unless String === link_field || Symbol === link_field || link_field == nil
      f_name = name.intern
      f_type = type
      f_json = json == false ? false : json&.intern || f_name
      f_json_ids = json_ids == false ? false : json_ids&.intern || "#{ f_json }_ids".intern
      f_link_table = link_table&.intern || "#{ self.short_name&.downcase }_#{ f_name }".intern
      f_back_field = back_field&.intern || "#{ self.short_name&.downcase }_id".intern
      f_link_field = link_field&.intern || "#{ type.short_name&.downcase }_id".intern
      fld = LinksField::new(self, f_name, f_type, f_json, f_json_ids, f_link_table, f_back_field, f_link_field)
      register_link_table fld
      define_links_field_methods fld
      fld
    end

    # @api internal
    def register_back_field field
      # TODO: implement
    end

    # @api internal
    def define_backs_field_methods field
      # TODO: implement
    end

    # @api DSL
    def backs name, type, json: nil, json_ids: nil, back_field: nil, owned: false
      raise ArgumentError, "Invalid field's name: #{ name.inspect }", caller unless String === name || Symbol === name
      raise ArgumentError, "Invalid field's type: #{ type.inspect }", caller unless Module === type
      raise ArgumentError, "Invalid 'json' option: #{ json.inspect }", caller unless String === json || Symbol === json || json == nil || json == false
      raise ArgumentError, "Invalid 'json_ids' option: #{ json_ids.inspect }", caller unless String === json_ids || Symbol === json_ids || json_ids == nil || json_ids == false
      raise ArgumentError, "Invalid 'back_field' option: #{ back_field.inspect }", caller unless String === back_field || Symbol === back_field || back_field == nil
      raise ArgumentError, "Invalid 'owned' option: #{ owned.inspect }", caller unless Boolean === owned || owned == nil
      f_name = name.intern
      f_type = type
      f_json = json == false ? false : json&.intern || f_name
      f_json_ids = json_ids == false ? false : json_ids&.intern || "#{ f_json }_ids".intern
      f_back_field = back_field&.intern || "#{ self.short_name&.intern }_id".intern
      f_owned = !!owned
      fld = BacksField::new(self, f_name, f_type, f_json, f_json_ids, f_back_field, f_owned)
      register_back_field fld
      define_backs_field_methods fld
      fld
    end

    # @api internal
    def define_custom_field_methods field
      fld = field
      if fld.getter
        var = "@#{ fld.name }".intern
        define_method fld.name do
          instance_variable_get(var)
        end
        define_method "#{ fld.name }=" do |value|
          val = instance_exec(value, &fld.parser)
          instance_variable_set(var, val)
          value
        end
      else
        define_method "#{ fld.name }=" do |value|
          instance_exec(value, &fld.parser)
          value
        end
      end
    end

    # @api DSL
    def custom name, json: nil, getter: true, &block
      raise ArgumentError, "Invalid custom field's name: #{ name.inspect }", caller unless String === name || Symbol === name
      raise ArgumentError, "Invalid 'json' option: #{ json.option }", caller unless String === json || Symbol === json || json == nil || json == false
      raise ArgumentError, "Invalid 'getter' option: #{ getter.option }", caller unless Boolean === getter
      raise ArgumentError, "Block must be given", caller unless block_given?
      f_name = name.intern
      f_json = json == false ? false : json&.intern || f_name
      f_getter = getter
      f_parser = block
      fld = CustomField::new(self, f_name, f_json, f_parser, f_getter)
      define_custom_field_methods fld
      fld
    end

    # @api DSL
    def primary_key name, fields
      # TODO: implement
    end

    # @api DSL
    def index name, fields
      # TODO: implement
    end

    # @api DSL
    def unique name, fields
      # TODO: implement
    end

    private :field, :links, :backs, :custom, :primary_key, :index, :unique

    # @!endgroup

    # @!group Metadata Information

    def fields with_parent = true
      @fields ||= {}
      result = with_parent && superclass.respond_to?(:fields) ? superclass.fields : {}
      result.merge @fields
    end

    def key
      @primary_key
    end

    def indexes with_parent = true
      @indexes ||= {}
      result = with_parent && superclass.respond_to?(:indexes) ? superclass.indexes : {}
      result.merge @indexes
    end

    def uniques with_parent = true
      @uniques ||= {}
      result = with_parent && superclass.respond_to?(:uniques) ? superclass.uniques : {}
      result.merge @uniques
    end

    def references with_parent = true
      @references ||= {}
      result = with_parent && superclass.respond_to?(:references) ? superclass.references : {}
      result.merge @references
    end

    # @!endgroup

    # @!group Global Metadata Information

    def link_tables
      @@link_tables ||= {}
      @@link_tables
    end

    # @!endgroup

  end

  # @api internal
  def initialize cache_key
    if self.class.key.size == 1
      instance_variable_set("@#{ self.class.key }".intern, cache_key)
    else
      self.class.key.zip(cache_key).each do |key, value|
        instance_variable_set("@#{ key }".intern, value)
      end
    end
    super(cache_key)
    @modified = Set::new
  end

  def key
    values = self.class.keys.map { |fld| self.send(fld) }
    if values.size == 1
      values.first
    else
      values
    end
  end

  def modified? name = nil
    @modified ||= Set::new
    if name
      @modified.include? name.intern
    else
      !@modified.empty?
    end
  end

  # @api internal
  def clear_modified
    @modified = Set::new
  end

end

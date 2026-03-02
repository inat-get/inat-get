# frozen_string_literal: true

require_relative 'scalar'

class INatGet::Data::Helper::Field::Has < INatGet::Data::Helper::Field::Scalar

  def initialize helper, key, association, extra = nil
    super helper, key, Boolean
    @association = association
    @extra = extra
  end

  def to_sequel(value)
    reflection = @helper.manager.model.association_reflection(@association)
    main_table = @helper.manager.model.table_name
    if reflection[:type] == :many_to_many
      join_table = reflection[:join_table]
      left_key = reflection[:left_key]
      right_key = reflection[:right_key]
      right_table = reflection.associated_class.table_name
      query = @helper.manager.model.db[join_table]
                                   .join(right_table, :id => right_key)
                                   .where(Sequel[join_table][left_key] => Sequel[main_table][:id])
      query = query.where(@extra) if @extra
      condition = query.exists
    else
      associated_class = reflection.associated_class
      foreign_key = reflection[:key]
      query = associated_class.where(foreign_key => Sequel[main_table][:id])
      query = query.where(@extra) if @extra
      condition = query.exists
    end
    value ? condition : Sequel.~(condition)
  end

end

# frozen_string_literals: true

Sequel.migration do

  change do

    alter_table :places do
      set_column_allow_null :slug, true
    end

  end

end

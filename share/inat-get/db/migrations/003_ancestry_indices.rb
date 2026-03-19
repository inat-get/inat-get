# frozen_string_literal: true

Sequel.migration do

  change do

    alter_table :taxa_ancestors do
      add_index [ :taxon_id ], name: 'ix_taxa_ancestors_taxon_id'
      add_index [ :ancestor_id ], name: 'ix_taxa_ancestors_ancestor_id'
    end

  end

end

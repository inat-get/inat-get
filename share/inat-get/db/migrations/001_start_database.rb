# frozen_string_literals: true

Sequel.migration do 

  change do 

    create_table :users do
      column :id, Integer, null: false
      column :login, String, null: false
      column :name, String
      column :created, Time
      column :orcid, String
      column :suspended, :boolean, null: false
      column :cached, Time, null: false

      primary_key [ :id ], name: 'pk_users'
      unique [ :login ], name: 'uq_users_login'
      index [ :created ], name: 'ix_users_created'
      index [ :suspended ], name: 'ix_users_suspended'
      index [ :cached ], name: 'ix_users_cached'
    end

    create_table :places do
      column :id, Integer, null: false
      column :slug, String, null: false
      column :name, String, null: false
      column :display_name, String
      column :admin_level, Integer
      column :place_type, Integer
      column :uuid, String
      column :bounding_box, String, text: true
      column :geometry, String, text: true
      column :latitude, Float
      column :longitude, Float
      column :cached, Time, null: false

      primary_key [ :id ], name: 'pk_places'
      unique [ :slug ], name: 'uq_places_slug'
      index [ :name ], name: 'ix_places_name'
      index [ :display_name ], name: 'ix_places_display_name'
      index [ :admin_level ], name: 'ix_places_admin_level'
      index [ :place_type ], name: 'ix_places_place_type'
      index [ :uuid ], name: 'ix_places_uuid'
      index [ :latitude ], name: 'ix_places_latitude'
      index [ :longitude ], name: 'ix_places_longitude'
      index [ :latitude, :longitude ], name: 'ix_places_location'
      index [ :cached ], name: 'ix_places_cached'
    end

    create_table :place_ancestors do
      column :place_id, Integer, null: false
      column :ancestor_id, Integer, null: false

      primary_key [ :place_id, :ancestor_id ], name: 'pk_place_ancestors'
      foreign_key [ :place_id ], :places, name: 'fk_place_ancestors_place_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :ancestor_id ], :places, name: 'fk_place_ancestors_ancestor_id', on_delete: :restrict, on_update: :cascade
      index [ :place_id ], name: 'ix_place_ancestors_place_id'
      index [ :ancestor_id ], name: 'ix_place_ancestors_ancestor_id'
    end

    create_table :projects do
      column :id, Integer, null: false
      column :slug, String, null: false
      column :title, String, null: false
      column :description, String, text: true
      column :created, Time, null: false
      column :updated, Time
      column :project_type, String
      column :is_umbrella, :boolean, null: false
      column :is_collection, :boolean, null: false
      column :members_only, :boolean, null: false
      column :user_id, Integer
      column :cached, Time, null: false

      primary_key [ :id ], name: 'pk_projects'
      foreign_key [ :user_id ], :users, name: 'fk_projects_user_id', on_delete: :restrict, on_update: :cascade
      unique [ :slug ], name: 'uq_projects_slug'
      index [ :title ], name: 'ix_projects_name'
      index [ :created ], name: 'ix_projects_created'
      index [ :updated ], name: 'ix_projects_updated'
      index [ :project_type ], name: 'ix_projects_type'
      index [ :is_umbrella ], name: 'ix_projects_is_umbrella'
      index [ :is_collection ], name: 'ix_projects_is_collection'
      index [ :cached ], name: 'ix_projects_cached'
    end

    create_table :project_admins do
      column :project_id, Integer, null: false
      column :user_id, Integer, null: false
      column :role, String

      primary_key [ :project_id, :user_id ], name: 'pk_project_admins'
      foreign_key [ :project_id ], :projects, name: 'fk_project_admins_project_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :user_id ], :users, name: 'fk_project_admins_user_id', on_delete: :cascade, on_update: :cascade
      index [:project_id, :role], name: 'ix_project_admins_project_role'
      index [:user_id, :role], name: 'ix_project_admins_user_role'
      index [:project_id, :user_id, :role], name: 'ix_project_admins_project_user_role'
    end

    create_table :project_places do
      column :project_id, Integer, null: false
      column :place_id, Integer, null: false
      column :exclude, :boolean, null: false

      primary_key [ :project_id, :place_id ], name: 'pk_project_places'
      foreign_key [ :project_id ], :projects, name: 'fk_project_places_project_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :place_id ], :places, name: 'fk_project_places_place_id', on_delete: :cascade, on_update: :cascade
      index [ :project_id, :exclude ], name: 'ix_project_places_project_exclude'
      index [ :project_id, :place_id, :exclude ], name: 'ix_project_places_exclude'
    end

    create_view :project_included_places,
      self[:project_places].select(:project_id, :place_id).where(exclude: false)

    create_view :project_excluded_places,
      self[:project_places].select(:project_id, :place_id).where(exclude: true)

    create_table :project_users do
      column :project_id, Integer, null: false
      column :user_id, Integer, null: false
      column :exclude, :boolean, null: false

      primary_key [ :project_id, :user_id ], name: 'pk_project_users'
      foreign_key [ :project_id ], :projects, name: 'fk_project_users_project_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :user_id ], :users, name: 'fk_project_users_user_id', on_delete: :cascade, on_update: :cascade
      index [ :project_id, :exclude ], name: 'ix_project_users_project_exclude'
      index [ :project_id, :user_id, :exclude ], name: 'ix_project_users_exclude'
    end

    create_view :project_included_users,
      self[:project_users].select(:project_id, :user_id).where(exclude: false)

    create_view :project_excluded_users,
      self[:project_users].select(:project_id, :user_id).where(exclude: true)

    create_table :project_quality_grades do
      column :project_id, Integer, null: false
      column :quality_grade, String, null: false

      primary_key [ :project_id, :quality_grade ], name: 'pk_project_quality_grades'
      foreign_key [ :project_id ], :projects, name: 'fk_project_quality_grades_project_id', on_delete: :cascade, on_update: :cascade
    end

    create_table :project_terms do
      column :project_id, Integer, null: false
      column :term_id, Integer, null: false
      column :term_value_id, Integer, null: false

      primary_key [ :project_id ], name: 'pk_project_terms'
      foreign_key [ :project_id ], :projects, name: 'fk_project_terms_project_id', on_delete: :cascade, on_update: :cascade
      index [ :project_id, :term_id ], name: 'ix_project_terms_term_id'
      index [ :project_id, :term_value_id ], name: 'ix_project_terms_term_value_id'
    end

    create_table :project_members do
      column :project_id, Integer, null: false
      column :user_id, Integer, null: false

      primary_key [ :project_id, :user_id ], name: 'pk_project_members'
      foreign_key [ :project_id ], :projects, name: 'fk_project_members_project_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :user_id ], :users, name: 'fk_project_members_user_id', on_delete: :cascade, on_update: :cascade
      index [ :project_id ], name: 'fk_project_members_project_id'
      index [ :user_id ], name: 'fk_project_members_user_id'
    end

    create_table :umbrella_projects do
      column :umbrella_id, Integer, null: false
      column :subproject_id, Integer, null: false

      primary_key [ :umbrella_id, :subproject_id ], name: 'pk_umbrella_projects'
      foreign_key [ :umbrella_id ], :projects, name: 'fk_umbrella_projects_umbrella_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :subproject_id ], :projects, name: 'fk_umbrella_projects_subproject_id', on_delete: :cascade, on_update: :cascade
      index [ :umbrella_id ], name: 'ix_umbrella_projects_umbrella_id'
      index [ :subproject_id ], name: 'ix_umbrella_projects_subproject_id'
    end

    create_table :taxa do
      column :id, Integer, null: false
      column :name, String, null: false
      column :common_name, String
      column :english_name, String
      column :iconic_taxon_id, Integer
      column :is_active, :boolean, null: false
      column :parent_id, Integer
      column :rank, String
      column :rank_level, Float
      column :cached, Time, null: false

      primary_key [ :id ], name: 'pk_taxa'
      foreign_key [ :iconic_taxon_id ], :taxa, name: 'fk_taxa_iconic_taxon_id', on_delete: :restrict, on_update: :cascade
      foreign_key [ :parent_id ], :taxa, name: 'fk_taxa_parent_id', on_delete: :cascade, on_update: :cascade
      index [ :name ], name: 'ix_taxa_name'
      index [ :common_name ], name: 'ix_taxa_common_name'
      index [ :english_name ], name: 'ix_taxa_english_name'
      index [ :iconic_taxon_id ], name: 'ix_taxa_iconic_taxon_id'
      index [ :is_active ], name: 'ix_taxa_is_active'
      index [ :parent_id ], name: 'ix_taxa_parent_id'
      index [ :rank_level ], name: 'ix_taxa_rank_level'
      index [ :cached ], name: 'ix_taxa_cached'
    end

    create_table :taxa_ancestors do
      column :taxon_id, Integer, null: false
      column :ancestor_id, Integer, null: false

      primary_key [ :taxon_id, :ancestor_id ], name: 'pk_taxa_ancestors'
      foreign_key [ :taxon_id ], :taxa, name: 'fk_taxa_ancestors_taxon_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :ancestor_id ], :taxa, name: 'fk_taxa_ancestors_ancestor_id', on_delete: :cascade, on_update: :cascade
    end

    create_table :project_taxa do
      column :project_id, Integer, null: false
      column :taxon_id, Integer, null: false
      column :exclude, :boolean, null: false

      primary_key [ :project_id, :taxon_id ], name: 'pk_project_taxa'
      foreign_key [ :project_id ], :projects, name: 'fk_project_taxa_project_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :taxon_id ], :taxa, name: 'fk_project_taxa_taxon_id', on_delete: :cascade, on_update: :cascade
      index [ :project_id, :exclude ], name: 'ix_project_taxa_project_exclude'
      index [ :project_id, :taxon_id, :exclude ], name: 'ix_project_taxa_exclude'
    end

    create_view :project_included_taxa,
      self[:project_taxa].select(:project_id, :taxon_id).where(exclude: false)

    create_view :project_excluded_taxa,
      self[:project_taxa].select(:project_id, :taxon_id).where(exclude: true)

    create_table :observations do
      column :id, Integer, null: false
      column :captive, :boolean
      column :created, Time, null: false
      column :created_year, Integer, null: false
      column :created_month, Integer, null: false
      column :created_week, Integer, null: false
      column :created_day, Integer, null: false
      column :created_hour, Integer, null: false
      column :created_timezone, String
      column :observed, Time
      column :observed_year, Integer
      column :observed_winter, Integer
      column :observed_month, Integer
      column :observed_week, Integer
      column :observed_day, Integer
      column :observed_hour, Integer
      column :observed_timezone, String
      column :updated, Time, null: false
      column :description, String, text: true
      column :geoprivacy, String
      column :taxon_geoprivacy, String
      column :license, String
      column :latitude, Float
      column :longitude, Float
      column :accuracy, Integer
      column :mappable, :boolean
      column :obscured, :boolean
      column :quality_grade, String, null: false
      column :taxon_id, Integer
      column :user_id, Integer, null: false
      column :uuid, String
      column :cached, Time, null: false

      primary_key [ :id ], name: 'pk_observations'
      foreign_key [ :taxon_id ], :taxa, name: 'fk_observations_taxon_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :user_id ], :users, name: 'fk_observations_user_id', on_delete: :cascade, on_update: :cascade
      index [ :captive ], name: 'ix_observations_captive'
      index [ :created ], name: 'ix_observations_created'
      index [ :created_year ], name: 'ix_observations_created_year'
      index [ :created_month ], name: 'ix_observations_created_month'
      index [ :created_week ], name: 'ix_observations_created_week'
      index [ :created_day ], name: 'ix_observations_created_day'
      index [ :created_hour ], name: 'ix_observations_created_hour'
      index [ :observed ], name: 'ix_observations_observed'
      index [ :observed_year ], name: 'ix_observations_observed_year'
      index [ :observed_month ], name: 'ix_observations_observed_month'
      index [ :observed_week ], name: 'ix_observations_observed_week'
      index [ :observed_day ], name: 'ix_observations_observed_day'
      index [ :observed_hour ], name: 'ix_observations_observed_hour'
      index [ :updated ], name: 'ix_observations_updated'
      index [ :geoprivacy ], name: 'ix_observations_geoprivacy'
      index [ :taxon_geoprivacy ], name: 'ix_observations_taxon_geoprivacy'
      index [ :license ], name: 'ix_observations_license'
      index [ :latitude ], name: 'ix_observations_latitude'
      index [ :longitude ], name: 'ix_observations_longitude'
      index [ :latitude, :longitude ], name: 'ix_observations_location'
      index [ :accuracy ], name: 'ix_observations_accuracy'
      index [ :mappable ], name: 'ix_observations_mappable'
      index [ :obscured ], name: 'ix_observations_obscured'
      index [ :quality_grade ], name: 'ix_observations_quality_grade'
      index [ :taxon_id ], name: 'ix_observations_taxon_id'
      index [ :user_id ], name: 'ix_observations_user_id'
      index [ :uuid ], name: 'ix_observations_uuid'
      index [ :cached ], name: 'ix_observations_cached'
    end

    create_table :observation_faves do
      column :observation_id, Integer, null: false
      column :user_id, Integer, null: false
      column :created, Time, null: false

      primary_key [ :observation_id, :user_id ], name: 'pk_observation_faves'
      foreign_key [ :observation_id ], :observations, name: 'fk_observation_faves_observation_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :user_id ], :users, name: 'fk_observation_faves_user_id', on_delete: :cascade, on_update: :cascade
      index [ :observation_id, :created ], name: 'ix_observation_faves_created'
    end

    create_table :annotations do
      column :observation_id, Integer, null: false
      column :term_id, Integer, null: false
      column :term_value_id, Integer, null: false
      column :user_id, Integer, null: false
      column :uuid, String
      column :vote_score, Integer, null: false

      primary_key [ :observation_id, :term_id, :term_value_id ], name: 'pk_annotations'
      foreign_key [ :observation_id ], :observations, name: 'fk_annotations_observation_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :user_id ], :users, name: 'fk_annotations_user_id', on_delete: :cascade, on_update: :cascade
      index [ :observation_id ], name: 'ix_annotations_observation_id'
      index [ :term_id ], name: 'ix_annotations_term_id'
      index [ :term_id, :term_value_id ], name: 'ix_annotations_term_and_value_id'
      index [ :term_value_id ], name: 'ix_annotations_term_value_id'
      index [ :uuid ], name: 'ix_annotations_uuid'
    end

    create_table :photos do
      column :id, Integer, null: false
      column :url, String, null: false
      column :license, String

      primary_key [ :id ], name: 'pk_photos'
      index [ :license ], name: 'ix_photos_license'
    end

    create_table :observation_photos do
      column :observation_id, Integer, null: false
      column :photo_id, Integer, null: false

      primary_key [ :observation_id, :photo_id ], name: 'pk_observation_photos'
      foreign_key [ :observation_id ], :observations, name: 'fk_observation_photos_observation_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :photo_id ], :photos, name: 'fk_observation_photos_photo_id', on_delete: :cascade, on_update: :cascade
      index [ :observation_id ], name: 'ix_observation_photos_observation_id'
    end

    create_table :sounds do
      column :id, Integer, null: false
      column :url, String, null: false
      column :license, String

      primary_key [ :id ], name: 'pk_sounds'
      index [ :license ], name: 'ix_sounds_license'
    end

    create_table :observation_sounds do
      column :observation_id, Integer, null: false
      column :sound_id, Integer, null: false

      primary_key [ :observation_id, :sound_id ], name: 'pk_observation_sounds'
      foreign_key [ :observation_id ], :observations, name: 'fk_observation_sounds_observation_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :sound_id ], :sounds, name: 'fk_observation_sounds_sound_id', on_delete: :cascade, on_update: :cascade
      index [ :observation_id ], name: 'ix_observation_sounds_observation_id'
    end

    create_table :observation_places do
      column :observation_id, Integer, null: false
      column :place_id, Integer, null: false

      primary_key [ :observation_id, :place_id ], name: 'pk_observation_places'
      foreign_key [ :observation_id ], :observations, name: 'fk_observation_places_observation_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :place_id ], :places, name: 'fk_observation_places_place_id', on_delete: :cascade, on_update: :cascade
      index [ :observation_id ], name: 'ix_observation_places_observation_id'
      index [ :place_id ], name: 'ix_observation_places_place_id'
    end

    create_table :observation_projects do
      column :observation_id, Integer, null: false
      column :project_id, Integer, null: false

      primary_key [ :observation_id, :project_id ], name: 'pk_observation_projects'
      foreign_key [ :observation_id ], :observations, name: 'fk_observation_projects_observation_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :project_id ], :projects, name: 'fk_observation_projects_project_id', on_delete: :cascade, on_update: :cascade
      index [ :observation_id ], name: 'ix_observation_projects_observation_id'
      index [ :project_id ], name: 'ix_observation_projects_project_id'
    end

    create_table :observation_tags do
      column :observation_id, Integer, null: false
      column :tag, String, null: false

      primary_key [ :observation_id, :tag ], name: 'pk_observation_tags'
      foreign_key [ :observation_id ], :observations, name: 'fk_observation_tags_observation_id', on_delete: :cascade, on_update: :cascade
      index [ :observation_id ], name: 'ix_observation_tags_observation_id'
      index [ :tag ], name: 'ix_observation_tags_tag'
    end

    create_table :identifications do
      column :observation_id, Integer, null: false
      column :id, Integer, null: false
      column :body, String, text: true
      column :category, String
      column :created, Time, null: false
      column :current, :boolean
      column :disagreement, :boolean
      column :hidden, :boolean
      column :own_observation, :boolean
      column :vision, :boolean
      column :taxon_id, Integer, null: false
      column :user_id, Integer, null: false
      column :uuid, String
      column :cached, Time, null: false

      primary_key [ :id ], name: 'pk_identifications'
      foreign_key [ :observation_id ], :observations, name: 'fk_identifications_observation_id', on_delete: :cascade, on_update: :cascade
      foreign_key [ :taxon_id ], :taxa, name: 'fk_identifications_taxon_id', on_delete: :restrict, on_update: :cascade
      foreign_key [ :user_id ], :users, name: 'fk_identifications_user_id', on_delete: :restrict, on_update: :cascade
      index [ :observation_id ], name: 'ix_identifications_observation_id'
      index [ :category ], name: 'ix_identifications_category'
      index [ :created ], name: 'ix_identifications_created'
      index [ :current ], name: 'ix_identifications_current'
      index [ :disagreement ], name: 'ix_identifications_disagreement'
      index [ :hidden ], name: 'ix_identifications_hidden'
      index [ :own_observation ], name: 'ix_identifications_own_observation'
      index [ :vision ], name: 'ix_identifications_vision'
      index [ :taxon_id ], name: 'ix_identifications_taxon_id'
      index [ :user_id ], name: 'ix_identifications_user_id'
      index [ :uuid ], name: 'ix_identifications_uuid'
      index [ :cached ], name: 'ix_identifications_cached'
    end

    create_table :requests do
      column :full, String, fixed: true, size: 32, null: false
      column :endless, String, fixed: true, size: 32, null: false
      column :endpoint, String, null: false
      column :query, String, text: true, null: false
      column :started, Time, null: false
      column :freshed, Time, null: false
      column :finished, Time
      column :busy,Time

      primary_key [ :full ], name: 'pk_requests'
      index [ :endless ], name: 'ix_requests_endless'
      index [ :endpoint ], name: 'ix_requests_endpoint'
      index [ :started ], name: 'ix_requests_started'
      index [ :freshed ], name: 'ix_requests_freshed'
      index [ :finished ], name: 'ix_requests_finished'
    end

    create_table :request_projects do
      column :request_hash, String, fixed: true, size: 32, null: false
      column :project_id, Integer, null: false

      primary_key [ :request_hash, :project_id ], name: 'pk_request_projects'
      foreign_key [ :request_hash ], :requests, name: 'fk_request_projects_request_hash', on_delete: :cascade, on_update: :cascade
      foreign_key [ :project_id ], :projects, name: 'fk_request_projects_project_id', on_delete: :cascade, on_update: :cascade
      index [ :request_hash ], name: 'ix_request_projects_request_hash'
      index [ :project_id ], name: 'ix_request_projects_project_id'
    end

    create_table :request_places do
      column :request_hash, String, fixed: true, size: 32, null: false
      column :place_id, Integer, null: false

      primary_key [ :request_hash, :place_id ], name: 'pk_request_places'
      foreign_key [ :request_hash ], :requests, name: 'fk_request_places_request_hash', on_delete: :cascade, on_update: :cascade
      foreign_key [ :place_id ], :places, name: 'fk_request_places_place_id', on_delete: :cascade, on_update: :cascade
      index [ :request_hash ], name: 'ix_request_places_request_hash'
      index [ :place_id ], name: 'ix_request_places_place_id'
    end

    create_table :request_taxa do
      column :request_hash, String, fixed: true, size: 32, null: false
      column :taxon_id, Integer, null: false

      primary_key [ :request_hash, :taxon_id ], name: 'pk_request_taxa'
      foreign_key [ :request_hash ], :requests, name: 'fk_request_taxa_request_hash', on_delete: :cascade, on_update: :cascade
      foreign_key [ :taxon_id ], :taxa, name: 'fk_requests_taxa_taxon_id', on_delete: :cascade, on_update: :cascade
      index [ :request_hash ], name: 'ix_request_taxa_request_hash'
      index [ :taxon_id ], name: 'ix_request_taxa_taxon_id'
    end

    create_table :request_users do
      column :request_hash, String, fixed: true, size: 32, null: false
      column :user_id, Integer, null: false

      primary_key [ :request_hash, :user_id ], name: 'pk_request_users'
      foreign_key [ :request_hash ], :requests, name: 'fk_request_users_request_hash', on_delete: :cascade, on_update: :cascade
      foreign_key [ :user_id ], :users, name: 'fk_request_users_user_id', on_delete: :cascade, on_update: :cascade
      index [ :request_hash ], name: 'ix_request_users_request_hash'
      index [ :user_id ], name: 'ix_request_users_user_id'
    end

  end

end

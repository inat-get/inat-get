require 'logger'

require 'spec_helper'

require 'sequel'
Sequel.extension :migration
Sequel.extension :core_extensions
Sequel.datetime_class = Time
Sequel.database_timezone = :utc
Sequel.application_timezone = :local
DB = Sequel::sqlite
Sequel::Model.require_valid_table = false
Sequel::Model.strict_param_setting = false
Sequel::Model.raise_on_save_failure = true
Sequel::Migrator::run DB, 'share/inat-get/db/migrations/'
Sequel::Model.db = DB
DB::loggers << ::Logger::new('tmp/db.log', level: :debug)
DB.extend_datasets do
  def literal_datetime(value)
    "'#{value.xmlschema}'"
  end

  def literal_time(value)
    if value.instance_of?(::Time)
      "'#{value.xmlschema}'"
    else
      super(value)
    end
  end
end

require_relative '../lib/inat-get/app/setup'
INatGet::App::Setup::config[:offline] = true

require_relative '../lib/inat-get/data/managers/users'
require_relative '../lib/inat-get/data/managers/projects'
require_relative '../lib/inat-get/data/managers/observations'



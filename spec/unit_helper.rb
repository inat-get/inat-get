require 'spec_helper'

require 'sequel'
Sequel.extension :migration
DB = Sequel::mock
Sequel::Migrator::run DB, 'share/inat-get/db/migrations/'

Sequel::Model.db = DB
require_relative '../lib/inat-get/data/managers/projects'
require_relative '../lib/inat-get/data/managers/observations'



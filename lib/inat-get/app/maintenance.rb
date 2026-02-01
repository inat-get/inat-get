# frozen_string_literal: true

require 'uri'
require 'yaml'
require 'sequel'

require_relative '../info'

module INatGet::Maintenance

  OK            = 0
  DB_OK         = 0
  DB_NOT_EXISTS = 1
  DB_ERROR      = 2
  DB_NOT_ACTUAL = 3

  class << self

    def show_config config
      config.delete :maintenance
      config.delete :maintenance_params
      config.delete :tasks
      if config[:database] && config[:database][:password]
        config[:database][:password] = '******'
      end
      puts "🌿 \e[1miNatGet Config:\e[0m"
      YAML.dump(config, $stdout, stringify_names: true)
      puts '---'
      exit OK
    end

    def info config
      # TODO: implement
    end

    def db_check config, continue = false
      connect_string = config.dig :database, :connect
      uri = URI::parse connect_string
      if uri.scheme.downcase == 'sqlite'
        unless File.exist?(uri.path)
          $stderr.puts "❌ \e[1mDatabase file not found:\e[0m #{ uri.path }"
          exit DB_NOT_EXISTS
        end
      end
      db_opts = { user: config.dig(:database, :user), password: config.dig(:database, :password) }.compact
      begin
        db = Sequel.connect connect_string, **db_opts
      rescue => e
        $stderr.puts "❌ \e[1mDB Connection error:\e[0m #{ e.message }"
        exit DB_ERROR
      end
      Sequel.extension :migration
      migrator = Sequel::Migrator::migrator_class(migrations_path).new(db, migrations_path)
      md_ver = migrator.target
      db_ver = migrator.current
      if md_ver != db_ver
        $stderr.puts "🚨 \e[1mDatabase is not actual:\e[0m"
        $stderr.puts "    Target version: \e[1m#{ md_ver }\e[0m"
        $stderr.puts "   Current version: \e[1m#{ db_ver }\e[0m"
        exit DB_NOT_ACTUAL
      end
      unless continue
        $stderr.puts "✅ \e[1mDatabase is actual:\e[0m version \e[1m#{md_ver}\e[0m"
        exit DB_OK
      end
    end

    def db_update config
      # TODO: implement
    end

    def db_migrate config
      # TODO: implement
    end

    def db_create config
      # TODO: implement
    end

    def db_reset config
      # TODO: implement
    end

    private

    def migrations_path
      @migrations_path ||= File.expand_path(File.join(File.dirname(__FILE__), '../../../share/inat-get/db/migrations/'))
    end

  end

end

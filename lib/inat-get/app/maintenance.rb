# frozen_string_literal: true

require 'uri'
require 'yaml'
require 'sequel'
Sequel.extension :migration

require_relative '../info'

module INatGet::App; end

module INatGet::App::Maintenance

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
      exit Errno::NOERROR::Errno
    end

    def info config
      # TODO: implement
    end

    def db_check config, continue = false
      connect_string = config.dig :database, :connect
      uri = URI::parse connect_string
      if file_based?(uri)
        unless File.exist?(uri.path)
          $stderr.puts "❌ \e[1mDatabase file not found:\e[0m #{ uri.path }"
          exit Errno::ENOENT::Errno
        end
      end
      db_opts = { user: config.dig(:database, :user), password: config.dig(:database, :password) }.compact
      begin
        db = Sequel.connect connect_string, **db_opts
      rescue => e
        $stderr.puts "❌ \e[1mDB Connection error:\e[0m #{ e.message }"
        exit Errno::ECONNREFUSED::Errno
      end
      Sequel.extension :migration
      migrator = Sequel::Migrator::migrator_class(migrations_path).new(db, migrations_path)
      md_ver = migrator.target
      db_ver = migrator.current
      if md_ver != db_ver
        $stderr.puts "🚨 \e[1mDatabase is not actual:\e[0m"
        $stderr.puts "    Target version: \e[1m#{ md_ver }\e[0m"
        $stderr.puts "   Current version: \e[1m#{ db_ver }\e[0m"
        exit Errno::ECANCELED::Errno
      end
      unless continue
        $stderr.puts "✅ \e[1mDatabase is actual:\e[0m version \e[1m#{md_ver}\e[0m"
        exit Errno::NOERROR::Errno
      end
      db.transaction(isolation: :committed) do
        # Чистим зависшие запросы
        db[:requests].where(Sequel.|({ finished: nil }, Sequel.~({ busy: nil }))).delete
      end
      Sequel::DATABASES.each(&:disconnect)
      true
    end

    def db_update config
      run_migration config
      exit Errno::NOERROR::Errno
    end

    def db_migrate config
      target = config[:maintenance_params]
      unless target.is_a?(Integer)
        $stderr.puts "❌ \e[1mVersion must be an integer\e[0m"
        exit Errno::ECANCELED::Errno
      end
      run_migration config, target: target
      exit Errno::NOERROR::Errno
    end

    def db_create config
      connect_string = config.dig :database, :connect
      uri = URI.parse connect_string
      db_opts = { user: config.dig(:database, :user), password: config.dig(:database, :password) }.compact
      if file_based?(uri)
        path = File.expand_path uri.path
        if File.exist?(path)
          $stderr.puts "❌ \e[1mDatabase file already exists:\e[0m #{ path }"
          exit Errno::EEXIST::Errno
        end
        FileUtils.mkdir_p File.dirname(path)
        db = Sequel.connect(connect_string, **db_opts)
        db.disconnect
        puts "✅ \e[1mDatabase file created:\e[0m #{ path }"
      else
        begin
          db = Sequel.connect(connect_string, **db_opts)
          db.test_connection
          db.disconnect
          puts "✅ \e[1mDatabase connection verified (#{ uri.scheme })\e[0m"
        rescue => e
          $stderr.puts "❌ \e[1mCannot connect to database:\e[0m"
          $stderr.puts "   #{ e.message }"
          $stderr.puts "   Please create database manually first"
          exit Errno::ECONNREFUSED::Errno
        end
      end
      begin
        run_migrations(config)
      rescue => e
        $stderr.puts "❌ \e[1mError while creating:\e[0m"
        $stderr.puts "   #{ e.message }"
        exit Errno::ECANCELED::Errno
      end
      puts "✅ \e[1mDatabase successfully created\e[0m"
      exit Errno::NOERROR::Errno
    end

    def db_reset config
      connect_string = config.dig :database, :connect
      db_opts = { user: config.dig(:database, :user), password: config.dig(:database, :password) }.compact
      uri = URI.parse connect_string
      if file_based?(uri)
        path = File.expand_path uri.path
        if File.exist?(path)
          File.delete path
          puts "🗑️  \e[1mDatabase file removed:\e[0m #{ path }"
        end
      else
        begin
          db = Sequel.connect(connect_string, **db_opts)
          tables = db.tables
          if tables.any?
            mysql_mode = uri.scheme =~ /mysql/i
            if mysql_mode
              db.execute "SET FOREIGN_KEY_CHECKS = 0"
            end
            tables.each do |table|
              db.drop_table table, cascade: !mysql_mode
            end
            if mysql_mode
              db.execute "SET FOREIGN_KEY_CHECKS = 1"
            end
            puts "🗑️  \e[1mAll tables dropped (#{ tables.size }):\e[0m #{ tables.join(", ") }"
          else
            puts "⚠️  \e[1mNo tables found in database\e[0m"
          end
          db.disconnect
        rescue => e
          $stderr.puts "❌ \e[1mError resetting database:\e[0m #{ e.message }"
          exit Errno::ECONNREFUSED::Errno
        end
      end
      puts "🔄 \e[1mRecreating database...\e[0m"
      db_create(config)
    end

    private

    def run_migrations config, target: nil
      connect_string = config.dig :database, :connect
      db_opts = { user: config.dig(:database, :user), password: config.dig(:database, :password) }.compact
      db = Sequel.connect(connect_string, **db_opts)
      opts = { target: target }.compact
      Sequel::Migrator.run(db, migrations_path, **opts)
      migrator = Sequel::Migrator.migrator_class(migrations_path).new(db, migrations_path)
      puts "✅ \e[1mDatabase migrated:\e[0m version \e[1m#{ migrator.current }\e[0m"
      db.disconnect
    rescue => e
      $stderr.puts "❌ \e[1mMigration error:\e[0m #{ e.message }\n#{ e.backtrace.inspect }"
      exit Errno::ECANCELED::Errno
    end

    def file_based? uri
      uri.scheme.downcase == 'sqlite'
    end

    def migrations_path
      @migrations_path ||= File.expand_path(File.join(File.dirname(__FILE__), '../../../share/inat-get/db/migrations/'))
    end

  end

end

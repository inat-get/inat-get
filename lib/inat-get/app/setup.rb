# frozen_string_literal: false

require 'yaml'
require 'optparse'

require 'is-dsl'
require 'is-deep'

require_relative '../info'
require_relative 'maintenance'

module INatGet::App; end

module INatGet::App::Setup

  DEFAULTS = {
    logs: {
      screen: {
        api: 'warn',
        sys: 'warn',
        wrk: 'info'
      },
      file: {
        enable: false,
        path: "./#{ INatGet::Info::NAME }.log",
        api: 'info',
        sys: 'info',
        wrk: 'info'
      }
    },
    database: {
      connect: "sqlite://${HOME}/.cache/#{ INatGet::Info::NAME }/#{ INatGet::Info::NAME }.db",
      user: nil,
      password: nil
    },
    caching: {
      update: '4h',
      refresh: { 
        interval: '4d',
        depth: '40d'
      },
      recache: { 
        count: 200,
        method: 'oldest'          # oldest by cached, newest by updated, sample — random
      },
      refs: {
        default: '4w',
        projects: '1w',
        taxa: '4w',
        users: '10w',
        places: '10w'
      }
    },
    offline: false,
    workers: {
      limit: 4,
      order: 'given'              # given, random, name
    },
    api: {
      root: 'https://api.inaturalist.org/v1/',
      locale: 'ru',
      preferred_place: 7161,
      translate_projects: 'umbrella',    # all | umbrella | none
      retry: {
        max: 5,
        interval: '1s',
        randomness: 0.5,
        backoff: 2
      },
      delay: '1s',
      pager: 200
    },
    socket: {
      console: "/tmp/#{ INatGet::Info::NAME }/console.sock",
      api: "/tmp/#{ INatGet::Info::NAME }/api.sock"
    },
    tasks: []
  }

  class << self

    def config! **opts
      @config = DEFAULTS.deep_dup
      options, tasks = parse_options!
      options[:tasks] = tasks
      config = load_config options[:config]
      @config.deep_merge! config
      @config.deep_merge! options
      @config.deep_merge! opts
      inject_env! @config
      unwrap_files!
      INatGet::App::Maintenance.send @config[:maintenance], @config if @config[:maintenance]
      @config
    end

    def config
      @config ||= DEFAULTS.deep_dup
    end

    private

    def inject_env! data
      case data
      when Hash
        data.transform_values! { |v| inject_env!(v) }
      when Array
        data.each_index do |idx|
          data[idx] = inject_env!(data[idx])
        end
        data
      when String
        data.gsub(/\$\{\s*(?<variable>[a-z_]\w*)\s*\}/i) do |match|
          ENV["INATGET_#{ $~[:variable] }"] || ENV[$~[:variable]] || ''
        end || data
      else
        data
      end
    end

    def parse_options!
      options = {
        :config => "~/.config/#{ INatGet::Info::NAME }.yml",
        :maintenance => nil,
        :maintenance_params => nil
      }

      opts = OptionParser::new do |o|
        o.banner = "🌿 \e[1miNatGet v#{INatGet::Info::VERSION} (#{INatGet::Info::VERSION_ALIAS}):\e[0m #{INatGet::Info::DESCRIPTION}\n" +
                   "          License: \e[1mGNU GPLv3+\e[0m (#{INatGet::Info::LICENSE_URL})\n" +
                   "           Author: \e[1m#{INatGet::Info::AUTHOR}\e[0m (#{INatGet::Info::AUTHOR_URL})\n" +
                   "         Homepage: \e[1m#{INatGet::Info::HOMEPAGE}\e[0m\n\n" +
                   "\e[1m   Usage:\e[0m #{INatGet::Info::NAME} [options] ‹task› [‹task› ...]"

        o.separator ''
        o.separator "\e[1m   Info Options:\e[0m"

        o.on '-h', '--help', 'Show this help and exit.' do
          puts opts.help
          exit 0
        end

        o.on '--version', 'Show version and exit.' do
          puts INatGet::Info::VERSION
          exit 0
        end

        o.on '-i', '--info', 'Show information about DB status and API connection. Then exit.' do
          options[:maintenance] = :info
        end

        o.on '--show-config', 'Show current configuration and exit.' do
          options[:maintenance] = :show_config
        end

        o.separator ''
        o.separator "\e[1m   Main Options:\e[0m"

        o.on '-c', '--config FILE', String, 'Use this file as config (must be YAML) [default: ~/.config/inat-get.yml].' do |value|
          options[:config] = value
        end

        o.on '-l', '--log-level LEVEL', [ 'fatal', 'error', 'warn', 'info', 'debug' ], 'Log level (fatal, error, warn, info or debug).' do |value|
          options[:logs] ||= {}
          options[:logs][:screen] ||= {}
          options[:logs][:screen][:api] = value
          options[:logs][:screen][:sys] = value
          options[:logs][:screen][:wrk] = value
        end

        o.on '-L', '--log-file [FILE]', String, 'Set log file path (if specified) and enable logging to file.' do |value|
          options[:logs] ||= {}
          options[:logs][:file] ||= {}
          options[:logs][:file][:path] = value if value
          options[:logs][:file][:enable] = true
        end

        o.on '--file-log-level LEVEL', [ 'fatal', 'error', 'warn', 'info', 'debug' ], 'Log level for file logging (fatal, error, warn, info or debug).' do |value|
          options[:logs] ||= {}
          options[:logs][:file] ||= {}
          options[:logs][:file][:api] = value
          options[:logs][:file][:sys] = value
          options[:logs][:file][:wrk] = value
        end

        o.on '--debug', 'Enable file logging and set file log level to debug.' do
          options[:logs] ||= {}
          options[:logs][:file] ||= {}
          options[:logs][:file][:enable] = true
          options[:logs][:file][:api] = 'debug'
          options[:logs][:file][:sys] = 'debug'
          options[:logs][:file][:wrk] = 'debug'
        end

        o.on '-o', '--offline', 'Offline mode: no updates, use local database only.' do 
          options[:offline] = true
        end

        o.on '-O', '--online', 'Online mode [default], use this flag to cancel \'offline: true\' in config.' do
          options[:offline] = false
        end

        o.separator ''
        o.separator "\e[1m   DB Maintenance:\e[0m"

        o.on '-C', '--db-check', 'Check DB version and exit.' do
          options[:maintenance] = :db_check
        end

        o.on '-U', '--db-update', 'Migrate to latest DB version and exit.' do
          options[:maintenance] = :db_update
        end

        o.on '-M', '--db-migrate VER', Integer, 'Migrate to DB version VER and exit.' do |value|
          options[:maintenance] = :db_migrate
          options[:maintenance_params] = value
        end

        o.on '--db-create', 'Create database (error if exists).' do
          options[:maintenance] = :db_create
        end

        o.on '--db-reset', 'Drop (if exists) and recreate database. All fetched data will be lost.' do
          options[:maintenance] = :db_reset
        end

        o.separator ''
        o.separator "\e[1m   File Arguments:\e[0m"

        o.separator "\t‹task› [‹task› ...]\t     One or more names of task files or list files with '@' prefix (one task\n" +
                    "\t\t\t\t     file per line). If task name has not extension try to read '‹task›'\n" +
                    "\t\t\t\t     than '‹task›.inat' than '‹task›.rb'."
      end

      begin
        files = opts.parse!
      rescue => e
        $stderr.puts "❌ \e[1m#{ e.message }\e[0m"
        exit Errno::ENOTSUP::Errno
      end

      [options, files]
    end

    def load_config filename
      filename = File.expand_path filename
      if File.exist?(filename)
        YAML::load_file filename, symbolize_names: true
      else
        warn "🚨 \e[1mConfig file not found:\e[0m #{ filename }\e[1m. Use defaults.\e[0m"
        {}
      end
    end

    def unwrap_files!
      return unless @config[:tasks]
      @config[:tasks] = unwrap_file_list @config[:tasks]
      @config
    end

    def unwrap_file_list list
      list.map do |file|
        if file.empty?
          []
        elsif file =~ /^@.*/
          list_file = file[1..]
          if File.exist?(list_file)
            unwrap_file_list File.readlines(list_file, chomp: true)
          else
            $stderr.puts "❌ \e[1mList file not found:\e[0m #{ list_file }\e[1m. Stopped!\e[0m" 
            exit Errno::ENOENT::Errno
          end
        else
          if File.exist?(file)
            file
          elsif File.exist?("#{ file }.inat")
            "#{ file }.inat"
          elsif File.exist?("#{ file }.rb")
            "#{ file }.rb"
          else
            $stderr.puts "❌ \e[1mTask file not found:\e[0m #{ file }\e[1m. Stopped!\e[0m"
            exit Errno::ENOENT::Errno
          end
        end
      end.flatten
    end

  end

end


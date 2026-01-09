# frozen_string_literal: true

require 'yaml'
require 'optparse'

require 'is-dsl'

require_relative '../info'
require_relative '../utils/deep_merge'

module INatGet::Setup

  DEFAULTS = {
    :logger => {
      :level => :info
    }
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
      unwrap_files!
    end

    def config
      @config ||= DEFAULTS.deep_dup
    end

    private

    def parse_options!
      options = {
        :config => "./inat-get.yml",
        :log_level => :warn,
        :maintenance => nil,
        :maintenance_params => nil
      }

      opts = OptionParser::new do |o|
        o.banner = "🌿 \e[1miNatGet v#{INatGet::Info::VERSION}:\e[0m #{INatGet::Info::DESCRIPTION}\n" +
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

        o.separator ''
        o.separator "\e[1m   Config Options:\e[0m"

        o.on '-c', '--config FILE', String, 'Use this file as config (must be YAML) [default: ./inat-get.yml].' do |value|
          options[:config] = value
        end

        o.on '-l', '--log-level LEVEL', [ 'fatal', 'error', 'warn', 'info', 'debug' ], 'Log level (fatal, error, warn, info or debug) [default: warn].' do |value|
          options[:log_level] = value
        end

        o.on '--debug', 'Set log level to debug.' do
          options[:log_level] = :debug
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

        o.separator "\t‹task› [‹task› ...]\t     One or more names of task files or list files with '@' prefix (one task file per line).\n" +
                    "\t\t\t\t     If task name has not extension try to read '‹task›' than '‹task›.inat' than '‹task›.rb'."
      end

      files = opts.parse!

      [options, files]
    end

    def load_config filename
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

module ING

  extend IS::DSL

  encapsulate INatGet::Setup, :config!, :config

end

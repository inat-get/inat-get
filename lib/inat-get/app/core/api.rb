# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'faraday/typhoeus'
# require 'faraday/gzip'
# require 'faraday-http-cache'
require 'is-duration'

require_relative 'server'
require_relative 'console_logger'
require_relative 'api_cache'

class INatGet::App::Server::API < INatGet::App::Server

  def initialize socket_path, **params
    @console = params.delete :console
    @logger = ::INatGet::App::ConsoleLogger::new @console, progname: 'API'
    super(socket_path, **params)
    @config = INatGet::App::Setup::config
    @delay = IS::Duration::parse @config.dig(:api, :delay)
  end

  private

  def get query, **opts
    endpoint = @config.dig(:api, :root) + query[:endpoint].to_s
    @logger.info query[:endpoint].to_s
    timepoint = Time::now
    if @last_request
      delta = timepoint - @last_request
      sleep (@delay - delta) if delta < @delay
    end
    @last_request = timepoint
    response = faraday.get(endpoint) do |rq|
      rq.params[:per_page] = @config.dig(:api, :pager)
      rq.params.compact!
      rq.params.merge! query[:query]
      rq.headers["User-Agent"] = "iNatGet v#{INatGet::Info::VERSION} (#{ INatGet::Info::VERSION_ALIAS })"
    end
    @logger.clear
    if response.success?
      begin
        data = JSON.parse response.body, symbolize_names: true
        return data.freeze
      rescue => e
        @logger.error "Error while parsing: #{e.message}"
        return { status: :error, error: e.message }.freeze
      end
    else
      @logger.error "Error in response: #{response.status}"
      return { status: :error, error: response.status }.freeze
    end
  rescue => e
    return { status: :error, error: e.message }.freeze
  end

  def faraday
    @faraday ||= Faraday::new do |f|
      f.request :retry,
                max: @config.dig(:api, :retry, :max),
                interval: IS::Duration::parse(@config.dig(:api, :retry, :interval)),
                interval_randomness: @config.dig(:api, :retry, :randomness),
                backoff_factor: @config.dig(:api, :retry, :backoff),
                retry_block: lambda { |env:, options:, retry_count:, exception:, will_retry_in:| @logger.warn "retry... : #{ retry_count } : #{ exception.class }" },
                exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed, Faraday::SSLError, Faraday::ClientError]
      f.request :url_encoded

      f.response :raise_error

      f.adapter :typhoeus do |typhoeus|
        typhoeus.options[:connecttimeout] = 5
        typhoeus.options[:timeout] = 10
        typhoeus.options[:nosignal] = 1
        typhoeus.options[:dns_cache_timeout] = 0
      end
    end
  end

end

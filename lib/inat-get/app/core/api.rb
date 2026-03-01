# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'is-duration'

require_relative 'server'
require_relative 'console_logger'

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
  end

  def faraday
    # tmp_logger = ::Logger::new 'common.log', level: :info
    @faraday ||= Faraday::new do |f|
      f.request :retry,
                max: @config.dig(:api, :retry, :max),
                interval: IS::Duration::parse(@config.dig(:api, :retry, :interval)),
                interval_randomness: @config.dig(:api, :retry, :randomness),
                backoff_factor: @config.dig(:api, :retry, :backoff),
                exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed, Faraday::SSLError, Faraday::ClientError]
      f.request :url_encoded
      # f.response :logger, tmp_logger, bodies: true, headers: true
      f.adapter Faraday::default_adapter
    end
  end

end

# frozen_string_literal: true

require_relative '../../utils/duration'
require_relative 'server'
require_relative 'console_logger'

class INatGet::Server::API < INatGet::Server

  def initialize socket_path, **params
    @console = params.delete :console
    @logger = ::INatGet::App::ConsoleLogger::new @console, progname: 'API'
    super(socket_path, **params)
    @config = INatGet::Setup::config
    @delay = INatGet::Utils::Duration::as_duration @config.dig(:api, :delay)
  end

  private

  def get query
    endpoint = @config.dig(:api, :root) + query[:endpoint]
    timepoint = Time::now
    if @last_request
      delta = timepoint - @last_request
      sleep (@delay - delta) if delta < @delay
    end
    @last_request = timepoint
    response = faraday.get endpoint do |rq|
      rq.params[:per_page] = @config.dig(:api, :pager)
      rq.params[:locale] = @config.dig(:api, :locale)
      rq.params[:preferred_place_id] = @config.dig(:api, :preferred_place)
      rq.params.compact!
      rq.params.merge! query[:params]
      rq.headers["User-Agent"] = "iNatGet v#{INatGet::Info::VERSION}"
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
    @faraday ||= Faraday::new do |f|
      f.request :retry,
                max: @config.dig(:api, :retry, :max),
                interval: INatGet::Utils::Duration::as_duration(@config.dig(:api, :retry, :interval)),
                interval_randomness: @config.dig(:api, :retry, :randomness),
                backoff_factor: @config.dig(:api, :retry, :backoff),
                exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed, Faraday::SSLError, Faraday::ClientError]
      f.request :url_encoded
      f.response :logger, @logger, bodies: true, headers: true
      f.adapter Faraday::default_adapter
    end
  end

end

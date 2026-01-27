# frozen_string_literal: true

require_relative 'core'

class INatGet::Actor::API < INatGet::Actor::Core

  def name
    'API'
  end

  def execute
    super

    require 'faraday'
    require 'faraday/retry'
    require_relative '../../utils/duration'

    @delay = INatGet::Utils::Duration::as_duration(@config.dig(:api, :delay)).to_f
    @logger.debug('SYS') { 'API Ractor started' }
    loop do
      msg = Ractor.receive
      pp msg
      @logger.debug('SYS') { "API Ractor received message: #{ msg.inspect }" }
      unless msg.is_a?(Hash) && msg[:command]
        @logger.error('SYS') { "API Ractor invalid message: #{ msg.inspect }" }
        next
      end
      case msg[:command]
      when :quit
        break
      else
        self.send msg[:command], msg[:data]
      end
    end
    @logger.debug('SYS') { 'API Ractor done' }
  end

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
      rq.headers['User-Agent'] = "iNatGet v#{ INatGet::Info::VERSION }"
    end
    if response.success?
      begin
        data = JSON.parse response.body, symbolize_names: true
        query[:worker].send data.freeze
      rescue => e
        query[:worker].send({ status: :error, error: e.message }.freeze)
        @logger.error "Error while parsing: #{ e.message }"
      end
    else
      query[:worker].send({ status: :error, error: response.status }.freeze)
      @logger.error "Error in response: #{ response.status }"
    end
  end

  private

  def faraday
    @faraday ||= Faraday::new do |f|
      f.request :retry,
                 max: @config.dig(:api, :retry, :max),
                 interval: INatGet::Utils::Duration::as_duration(@config.dig(:api, :retry, :interval)),
                 interval_randomness: @config.dig(:api, :retry, :randomness),
                 backoff_factor: @config.dig(:api, :retry, :backoff),
                 exceptions: [ Faraday::TimeoutError, Faraday::ConnectionFailed, Faraday::SSLError, Faraday::ClientError ]
      f.request :url_encoded
      f.response :logger, @logger, bodies: true, headers: true
      f.adapter Faraday::default_adapter
    end
  end

end

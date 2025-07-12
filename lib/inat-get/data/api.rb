# frozen_string_literals: true

require_relative '../core'

require 'httparty'

module INatGet::API

  class << self

    REQUEST_LIMIT = 100
    REQUEST_WINDOW = 60
    @request_timestamps = []
    @mutex = Mutex.new

    # @api private
    def get(endpoint, **query_params)
      with_rate_limit do
        url = "https://api.inaturalist.org/v1/#{ endpoint }"
        response = HTTParty.get(url, query: query_params)
        handle_response(response)
        response.parsed_response['results']&.first || response.parsed_response
      end
    end

    def query(endpoint, **query_params, &block)
      results = []
      page = query_params[:page] || 1
      per_page = [query_params[:per_page] || 100, 200].min
      url = "https://api.inaturalist.org/v1/#{ endpoint }"

      loop do
        with_rate_limit do
          response = HTTParty.get(url, query: query_params.merge(page: page, per_page: per_page))
          handle_response(response)
          page_results = response.parsed_response['results'] || []
          break if page_results.empty?
          page_results.each { |item| yield(item) if block }
          results.concat(page_results)
          page += 1
        end
      end
      results
    end

    private

    def with_rate_limit
      @mutex.synchronize do
        now = Time.now.to_f
        @request_timestamps.reject! { |ts| now - ts > REQUEST_WINDOW }
        if @request_timestamps.size >= REQUEST_LIMIT
          sleep_time = REQUEST_WINDOW - (now - @request_timestamps.first)
          sleep(sleep_time) if sleep_time > 0
          @request_timestamps.clear
        end
        result = yield
        @request_timestamps << Time.now.to_f
        result
      end
    end

    def handle_response(response)
      if response.code == 429
        raise "Rate limit exceeded despite preventive measures"
      elsif !response.success?
        raise "API error: #{ response.code } - #{ response.message }"
      end
    end

  end
end

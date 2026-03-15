# frozen_string_literal: true

require_relative '../../info'

module INatGet::App
  class Server
    class API < INatGet::App::Server; end
  end
end

# @api private
class INatGet::App::Server::API::Cache

  def initialize limit = 100
    @limit = limit
    @data = {}
  end

  def read key
    return nil unless @data.has_key?(key)
    value = @data.delete key
    @data[key] = value
    value
  end

  def write key, value
    @data.delete key
    @data[key] = value
    @data.shift if @data.size > @limit
    value
  end

  def delete key
    @data.delete key
  end

end

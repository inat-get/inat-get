# frozen_string_literal: true

require 'singleton'

require_relative '../info'

module INatGet::Data; end

class INatGet::Data::Updater

  include Singleton

  def update! *requests
    total = requests.size
    requests.each_with_index do |rq, idx|
      parser = rq.delete :parser
      shared = Ractor.make_shareable({
        total: total,
        current: idx,
        request: rq,
        worker: Ractor.current
      })
      Ractor[:api].send shared
      loop do
        response = Ractor.receive
        results = response[:results]
        parser.parse! results if results
        break if response[:done]
      end
    end
  end

end

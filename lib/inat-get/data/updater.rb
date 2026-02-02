# frozen_string_literal: true

require 'singleton'

require_relative '../info'

module INatGet::Data; end

class INatGet::Data::Updater

  include Singleton

  def update! *requests
    total = requests.size
    requests.each_with_index do |rq, idx|
      # TODO: implement
      # 
    end
  end

end

require 'unit_helper'

require_relative '../../lib/inat-get/data/parsers/observation'

RSpec::describe INatGet::Data::Parser do 

  it 'parse' do
    path = File.join __dir__, '../fixtures/data.json'
    json = JSON.parse File.read(path), symbolize_names: true
    parser = INatGet::Data::Parser::Observation::instance
    expect { parser.parse! json[:results] }.not_to raise_error()
  end

end

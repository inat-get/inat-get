require 'unit_helper'

require_relative '../../lib/inat-get/data/parsers/observation'

RSpec::describe INatGet::Data::Parser do 

  it 'parse' do
    path = File.join __dir__, '../fixtures/data.json'
    json = JSON.parse File.read(path), symbolize_names: true
    parser = INatGet::Data::Parser::Observation::instance
    expect { parser.parse! json[:results] }.not_to raise_error()

    dataset = parser.manager.get observed_year: 2026
    expect(dataset.count).to eq(94)
    species = dataset % INatGet::Data::Enum::Rank.species
    expect(species.count).to eq(13)
    genus = dataset % INatGet::Data::Enum::Rank.genus
    expect(genus.count).to eq(11)
    families = dataset % :family
    expect(families.count).to eq(5)
    places = dataset % :places
    expect(places.count).to eq(11)
  end

end

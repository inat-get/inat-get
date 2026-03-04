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

    taxa_man = families.first.key.class.manager

    poecile = taxa_man.get 144351
    passeriformes = taxa_man.get 7251
    ds_poecile = parser.manager.get taxon: poecile
    ds_passeriformes = parser.manager.get taxon: passeriformes
    ds_and = ds_poecile * ds_passeriformes
    ds_or = ds_poecile + ds_passeriformes
    expect(ds_and.count).to eq(ds_poecile.count)
    expect(ds_or.count).to eq(ds_passeriformes.count)

    sample = species.first.key
    expect(sample.iconic).to eq(INatGet::Data::Enum::Iconic::Aves())
  end

end

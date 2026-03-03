require 'unit_helper'
require_relative '../../lib/inat-get/data/helpers/observations'

RSpec::describe INatGet::Data::Helper::Observations do

  let(:manager) { INatGet::Data::Manager::Observations::instance }

  it 'identifiers' do
    expect { manager.get(id: [1, 2]).to_a }.not_to raise_error()
    expect { manager.get(id: 100).to_a }.not_to raise_error()
    expect { manager.get(uuid: [ '0d346930-6e62-483e-93b3-129e20821bb7' ]).to_a }.not_to raise_error()
    expect { manager.get(uuid: '0d346930-6e62-483e-93b3-129e20821bb7').to_a }.not_to raise_error()
    expect { manager.get(uuid: [ '' ]).to_a }.to raise_error(ArgumentError)
  end

  it 'booleans' do
    expect { manager.get(captive: true).to_a }.not_to raise_error()
    expect { manager.get(endemic: true).to_a }.not_to raise_error()
    expect { manager.get(identified: true).to_a }.not_to raise_error()
    expect { manager.get(native: true).to_a }.not_to raise_error()
    expect { manager.get(introduced: true).to_a }.not_to raise_error()
    expect { manager.get(out_of_range: true).to_a }.not_to raise_error()
    expect { manager.get(popular: true).to_a }.not_to raise_error()
    expect { manager.get(photos: true).to_a }.not_to raise_error()
    expect { manager.get(sounds: false).to_a }.not_to raise_error()
    expect { manager.get(threatened: true).to_a }.not_to raise_error()
    expect { manager.get(verifiable: true).to_a }.not_to raise_error()
    expect { manager.get(licensed: true).to_a }.not_to raise_error()
    expect { manager.get(photo_licensed: true).to_a }.not_to raise_error()
    expect { manager.get(sound_licensed: false).to_a }.not_to raise_error()
    expect { manager.get(mappable: true).to_a }.not_to raise_error()
    expect { manager.get(obscured: true).to_a }.not_to raise_error()
  end

  it 'licenses' do
    expect { manager.get(license: 'cc-by').to_a }.not_to raise_error()
    expect { manager.get(photo_license: 'cc-by').to_a }.not_to raise_error()
    expect { manager.get(sound_license: [ 'cc-by', 'cc-by-nc' ]).to_a }.not_to raise_error()
  end

  it 'dates' do
    today = Date::today
    expect { manager.get(created: today).to_a }.not_to raise_error()
    expect { manager.get(created: (... today)).to_a }.not_to raise_error()
    expect { manager.get(observed: today).to_a }.not_to raise_error()
    expect { manager.get(observed: (today ..)).to_a }.not_to raise_error()
    expect { manager.get(created_year: today.year).to_a }.not_to raise_error()
    expect { manager.get(created_month: today.month).to_a }.not_to raise_error()
    expect { manager.get(created_week: today.cweek).to_a }.not_to raise_error()
    expect { manager.get(created_day: today.day).to_a }.not_to raise_error()
    expect { manager.get(created_hour: 12).to_a }.not_to raise_error()
    expect { manager.get(observed_year: today.year).to_a }.not_to raise_error()
    expect { manager.get(observed_month: today.month).to_a }.not_to raise_error()
    expect { manager.get(observed_week: today.cweek).to_a }.not_to raise_error()
    expect { manager.get(observed_day: today.day).to_a }.not_to raise_error()
    expect { manager.get(observed_hour: 12).to_a }.not_to raise_error()
  end

  it 'accuracy' do
    expect { manager.get(accuracy: (0 .. 4)).to_a }.not_to raise_error()
    expect { manager.get(accuracy: (  .. 4)).to_a }.not_to raise_error()
  end

  it 'keys' do
    expect { manager.get(geoprivacy: 'test').to_a }.not_to raise_error()
    expect { manager.get(geoprivacy: [ 'test' ]).to_a }.not_to raise_error()
    expect { manager.get(taxon_geoprivacy: 'test').to_a }.not_to raise_error()
    expect { manager.get(taxon_geoprivacy: [ 'test' ]).to_a }.not_to raise_error()
    expect { manager.get(quality_grade: 'test').to_a }.not_to raise_error()
    expect { manager.get(quality_grade: [ 'test' ]).to_a }.not_to raise_error()
  end

  it 'iconic' do
    expect { manager.get(iconic_taxa: 'Aves').to_a }.not_to raise_error()
    expect { manager.get(iconic_taxa: [ 'Aves', 'Fungi' ]).to_a }.not_to raise_error()
  end

  # it 'location' do
  #   expect { manager.get(latitude: 50.0, longitude: 60.0, radius: 200).to_a }.not_to raise_error()
  #   expect { manager.get(latitude: (50.0 .. 60.0), longitude: (50 .. 60)).to_a }.not_to raise_error()
  # end

end

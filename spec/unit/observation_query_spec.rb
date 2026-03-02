require 'unit_helper'

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

end

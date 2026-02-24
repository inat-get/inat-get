require 'unit_helper'

require_relative '../../lib/inat-get/data/managers/observations'

RSpec::describe 'Offline mode' do

  it 'config option' do
    expect(INatGet::App::Setup::config[:offline]).to eq(true)
  end

  it 'get empty dataset' do
    dataset = INatGet::Data::Manager::Observations::instance.get quality_grade: 'research'
    expect(dataset.count).to eq(0)
  end

end

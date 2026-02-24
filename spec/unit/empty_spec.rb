require 'unit_helper'

require_relative '../../lib/inat-get/data/dsl/dsl'

RSpec::describe INatGet::Data::DSL do

  it 'module' do
    v = INatGet::Data::DSL::instance_methods.include? :version
    expect(v).to eq(true)
  end

end

require 'unit_helper'

require_relative '../../lib/inat-get/data/dsl/reports/erb'

class Wrapper
  include INatGet::Data::DSL

  def eval(&block)
    instance_eval(&block)
  end
end

RSpec::describe INatGet::Data::DSL::Report::ERB do

  it 'simple ERB' do
    wrp = Wrapper::new
    rep = wrp.eval { erb_report '<%= today %>' }
    expect(rep.render).to eq(Date::today.to_s)
  end

end

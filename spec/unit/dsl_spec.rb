require 'date'

require 'unit_helper'

require_relative '../../lib/inat-get/data/dsl/dsl'

class Wrapper

  include INatGet::Data::DSL

  def eval &block
    instance_eval(&block)
  end

end

RSpec::describe INatGet::Data::DSL do

  it 'module' do
    v = INatGet::Data::DSL::instance_methods.include? :version
    expect(v).to eq(true)
  end

  it 'check version' do
    obj = Wrapper::new
    expect(obj.eval { version }).to be_a(Gem::Version)
    expect { obj.eval { version! '~> 2.0' } }.to raise_error(Gem::DependencyError)
    expect(obj.eval { version! '~> 0.9' }).to eq(true)
  end

  it 'check ranges' do
    obj = Wrapper::new
    today = Date::today
    expect(obj.eval { time_range date: today }).to eq(today.to_datetime ... (today + 1).to_datetime)
    start = Date::new(1901, 1, 1).to_datetime
    finish = Date::new(2001, 1, 1).to_datetime
    expect(obj.eval { time_range century: 20 }).to eq(start ... finish)
    start = Date::new(2026, 4, 1).to_datetime
    finish = Date::new(2026, 7, 1).to_datetime
    expect(obj.eval { time_range year: 2026, quarter: 2 }).to eq(start ... finish)
    start = Date::new(2025, 12, 1).to_datetime
    finish = Date::new(2026, 3, 1).to_datetime
    expect(obj.eval { time_range year: 2026, season: :winter }).to eq(start ... finish)
  end

end

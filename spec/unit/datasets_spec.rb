require 'unit_helper'

require_relative '../../lib/inat-get/data/dsl/dataset'

RSpec::describe INatGet::Data::DSL::Dataset do

  before :all do
    um = INatGet::Data::Model::User
    om = INatGet::Data::Model::Observation
    om.db.transaction do
      point = Time::now
      u1 = um.create id: 1, login: 'first', suspended: false, cached: point
      u2 = um.create id: 2, login: "second", suspended: false, cached: point
      om.create id: 1, 
              created: point, created_year: point.year, created_month: point.month, created_week: point.to_date.cweek, created_day: point.day, created_hour: point.hour, 
              updated: point, quality_grade: 'research', user: u1, cached: point
      om.create id: 2, 
              created: point, created_year: point.year, created_month: point.month, created_week: point.to_date.cweek, created_day: point.day, created_hour: point.hour, 
              updated: point, quality_grade: "needs_id", user: u1, cached: point
      om.create id: 3, 
              created: point, created_year: point.year, created_month: point.month, created_week: point.to_date.cweek, created_day: point.day, created_hour: point.hour, 
              updated: point, quality_grade: "research", user: u2, cached: point
      om.create id: 4, 
              created: point, created_year: point.year, created_month: point.month, created_week: point.to_date.cweek, created_day: point.day, created_hour: point.hour, 
              updated: point, quality_grade: "needs_id", user: u2, cached: point
    end
  end

  after :all do
    um = INatGet::Data::Model::User
    om = INatGet::Data::Model::Observation
    om.db.transaction do
      om.exclude(id: nil).delete
      um.exclude(id: nil).delete
    end
  end

  it 'simple creation' do
    obs = INatGet::Data::Manager::Observations::instance.get quality_grade: 'research'
    expect(obs.count).to eq(2)
    usr = INatGet::Data::Manager::Users::instance[1]
    obs2 = INatGet::Data::Manager::Observations::instance.get quality_grade: 'needs_id', user: usr
    expect(obs2.count).to eq(1)
    obs3 = obs * obs2
    expect(obs3.count).to eq(0)
    obs4 = obs + obs2
    expect(obs4.count).to eq(3)
    obs5 = obs.where(user: usr)
    expect(obs5.count).to eq(1)
    expect(obs5.to_a.size).to eq(1)
    obs6 = obs - obs5
    expect(obs6.count).to eq(1)
  end

  it 'split' do
    obs = INatGet::Data::Manager::Observations::instance.get created_year: Time::now.year
    list = obs % :quality_grade
    expect(list.size).to eq(2)
    expect(list.keys.include?('research')).to eq(true)
    lst2 = obs % :user
    expect(lst2.size).to eq(2)
    expect(lst2.first.key.class).to eq(INatGet::Data::Model::User)
    expect(lst2.first.count).to eq(2)
  end

end

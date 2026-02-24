require 'unit_helper'

RSpec::describe INatGet::Data::DSL::Condition::OR do

  it 'empty construct' do
    condition = INatGet::Data::DSL::Condition::OR[]
    expect(condition).to eq(INatGet::Data::DSL::NOTHING)
  end

  it 'constructs' do
    condition = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    check = condition | INatGet::Data::DSL::NOTHING
    expect(check).to eq(condition)
    check = condition | INatGet::Data::DSL::ANYTHING
    expect(check).to eq(INatGet::Data::DSL::ANYTHING)
    check = INatGet::Data::DSL::Condition::OR[condition]
    expect(check).to eq(condition)
  end

  it 'flatten' do
    c1 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    c2 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: 'cc-by']
    c3 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, quality_grade: 'research']
    o1 = c1 | c2
    o2 = o1 | c3
    expect(o2.operands.size).to eq(3)
  end

  it 'equality' do
    c1 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    c2 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: "cc-by"]
    c3 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, quality_grade: "research"]
    o1 = c1 | c2 | c3
    o2 = c2 | c3 | c1
    o3 = o1 | o2
    expect(o1 == o2).to eq(true)
    expect(o1.equal? o2).to eq(false)
    expect(o2 == o3).to eq(true)
    expect(o3 == o1).to eq(true)
  end

  it 'api query' do
    c1 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    c2 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: "cc-by"]
    c3 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, quality_grade: "research"]
    o1 = c1 | c2 | c3
    qq = o1.api_query
    expect(qq.size).to eq(3)
    c4 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 2]
    o2 = c1 | c4
    qq = o2.api_query
    expect(qq.size).to eq(1)
    c5 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: ::Set[ 1, 2, 3 ]]
    o3 = c1 | c5
    qq = o3.api_query
    expect(qq.size).to eq(1)
    c6 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1, license: 'cc-by']
    c7 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 2, license: "cc-by"]
    o4 = c6 | c7
    qq = o4.api_query
    expect(qq.size).to eq(1)
  end

end

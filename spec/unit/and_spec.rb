require 'unit_helper'

RSpec::describe INatGet::Data::DSL::Condition::AND do

  it 'empty construct' do
    condition = INatGet::Data::DSL::Condition::AND[]
    expect(condition).to eq(INatGet::Data::DSL::ANYTHING)
  end

  it 'with nothing and anything' do
    condition = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    and_condition = INatGet::Data::DSL::Condition::AND[condition, INatGet::Data::DSL::NOTHING]
    expect(and_condition).to eq(INatGet::Data::DSL::NOTHING)
    and_condition = INatGet::Data::DSL::Condition::AND[condition, INatGet::Data::DSL::ANYTHING]
    expect(and_condition).to eq(condition)
  end

  it 'dedup and dup' do
    condition = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    and_condition = INatGet::Data::DSL::Condition::AND[condition, condition]
    expect(and_condition).to eq(condition)
    other = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: 'cc-by']
    and_condition = INatGet::Data::DSL::Condition::AND[condition, other]
    expect(and_condition.operands.size).to eq(2)
  end

  it 'equiv' do
    condition = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    other = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: "cc-by"]
    first = INatGet::Data::DSL::Condition::AND[condition, other]
    second = INatGet::Data::DSL::Condition::AND[other, condition]
    expect(first == second).to eq(true)
  end

  it 'and' do
    condition = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    other = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: "cc-by"]
    other2 = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, quality_grade: "research"]
    first = condition & other
    second = first & other2
    third = second & first
    expect(first.operands.size).to eq(2)
    expect(second.operands.size).to eq(3)
    expect(third.operands.size).to eq(3)
  end

  it 'model' do
    condition = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    other = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: "cc-by"]
    and_condition = condition & other
    expect(and_condition.model).to eq(condition.model)
  end

  it 'api query' do
    condition = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    other = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: "cc-by"]
    and_condition = condition & other
    query = and_condition.api_query.first[:query]
    expect(query).to eq({ id: ::Set[1], license: ::Set['cc-by'] })
  end

  it 'sequel query' do
    condition = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    other = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, license: "cc-by"]
    and_condition = condition & other
    # sq = and_condition.sequel_query
    expect(and_condition.sequel_query).to eq(Sequel.&(Sequel.&(id: 1), Sequel.&(license: ::Set['cc-by'])))
  end

end

require 'unit_helper'

RSpec::describe INatGet::Data::DSL::Condition::NOT do

  it 'double not' do
    q = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    n = !q
    nn = !n
    expect(nn).to eq(q)
  end

  it 'and or' do
    q = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    n = !q
    r1 = n & q
    expect(r1).to eq(INatGet::Data::DSL::NOTHING)
    r2 = n | q
    expect(r2).to eq(INatGet::Data::DSL::ANYTHING)
  end

  it 'consts' do
    expect(!INatGet::Data::DSL::NOTHING).to eq(INatGet::Data::DSL::ANYTHING)
    expect(!INatGet::Data::DSL::ANYTHING).to eq(INatGet::Data::DSL::NOTHING)
  end

  it 'normalize' do
    q = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    n = !q
    sq = n.sequel_query
    expect(sq.class).to eq(Sequel::SQL::BooleanExpression)
  end

end

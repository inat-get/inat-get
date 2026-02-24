require 'unit_helper'

RSpec::describe INatGet::Data::DSL::Condition::Query do
  
  it 'create an prepare' do
    query = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    qq = query.api_query
    expect(qq.first[:query]).to eq({ id: ::Set[1] })
  end

  it 'to_sequel' do
    query = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation, id: 1]
    sq = query.sequel_query
    expect(sq).to eq(Sequel.&(Sequel.|(id: 1)))
  end

  it 'creation and equality' do
    creator = INatGet::Data::DSL::Condition::Query[INatGet::Data::Model::Observation]
    q1 = creator[id: 1]
    q2 = creator[id: 2]
    q3 = creator[id: 1]
    expect(q1 == q3).to eq(true)
    expect(q1.equal? q3).to eq(false)
    expect(q1 != q2).to eq(true)
  end

end

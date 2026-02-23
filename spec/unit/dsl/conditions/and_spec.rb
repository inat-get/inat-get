# frozen_string_literal: true

require 'sequel'
db = Sequel.mock
Sequel::Model.db = db

require "spec_helper"
require 'support/mock_factories'

require_relative '../../../../lib/inat-get/data/dsl/conditions/and'
require_relative '../../../../lib/inat-get/data/dsl/conditions/query'

RSpec.describe INatGet::Data::DSL::Condition::AND do
  include MockFactories

  let(:model) { mock_model }

  describe ".[] constructor" do
    it "returns ANYTHING for empty operands" do
      expect(described_class[]).to be(INatGet::Data::DSL::ANYTHING)
    end

    it "returns NOTHING if any operand is NOTHING" do
      q = INatGet::Data::DSL::Condition::Query[model, id: 1]
      expect(described_class[q, INatGet::Data::DSL::NOTHING]).to be(INatGet::Data::DSL::NOTHING)
    end

    it "removes ANYTHING from operands" do
      q = INatGet::Data::DSL::Condition::Query[model, id: 1]
      result = described_class[q, INatGet::Data::DSL::ANYTHING]
      expect(result.operands).to eq([q])
    end
  end

  describe "#& operator" do
    it "flattens nested AND" do
      q1 = INatGet::Data::DSL::Condition::Query[model, id: 1]
      q2 = INatGet::Data::DSL::Condition::Query[model, id: 2]
      q3 = INatGet::Data::DSL::Condition::Query[model, id: 3]

      inner = described_class[q1, q2]
      outer = inner & q3

      expect(outer).to be_a(described_class)
      expect(outer.operands.size).to eq(3)
    end
  end

  describe "#==" do
    it "ignores operand order" do
      q1 = INatGet::Data::DSL::Condition::Query[model, id: 1]
      q2 = INatGet::Data::DSL::Condition::Query[model, id: 2]

      a = described_class[q1, q2]
      b = described_class[q2, q1]

      expect(a).to eq(b)
    end

    it "returns false for different operands" do
      q1 = INatGet::Data::DSL::Condition::Query[model, id: 1]
      q2 = INatGet::Data::DSL::Condition::Query[model, id: 2]
      q3 = INatGet::Data::DSL::Condition::Query[model, id: 3]

      a = described_class[q1, q2]
      b = described_class[q2, q3]

      expect(a).not_to eq(b)
    end
  end

  describe "#flatten" do
    it "flattens nested ANDs" do
      q1 = INatGet::Data::DSL::Condition::Query[model, id: 1]
      q2 = INatGet::Data::DSL::Condition::Query[model, id: 2]
      q3 = INatGet::Data::DSL::Condition::Query[model, id: 3]

      nested = described_class[q1, described_class[q2, q3]]
      flat = nested.flatten

      expect(flat.operands.size).to eq(3)
    end
  end

  describe "#to_sequel" do
    it "combines operands with AND" do
      q1 = INatGet::Data::DSL::Condition::Query[model, id: Set[1]]
      q2 = INatGet::Data::DSL::Condition::Query[model, quality_grade: Set["research"]]

      and_cond = described_class[q1, q2]
      sequel = and_cond.to_sequel

      expect(sequel).to be_a(Sequel::SQL::BooleanExpression)
    end
  end
end

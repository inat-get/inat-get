# frozen_string_literal: true

require "sequel"
require "spec_helper"
require "support/condition_test_helpers"

require_relative "../../../../lib/inat-get/data/dsl/conditions/base"
require_relative "../../../../lib/inat-get/data/dsl/conditions/and"
require_relative "../../../../lib/inat-get/data/dsl/conditions/or"
require_relative "../../../../lib/inat-get/data/dsl/conditions/not"
require_relative "../../../../lib/inat-get/data/dsl/conditions/query"

RSpec.describe INatGet::Data::DSL::Condition::AND do
  include ConditionTestHelpers

  let(:q1) { query(id: 1) }
  let(:q2) { query(id: 2) }
  let(:q3) { query(id: 3) }
  let(:q_status_a) { query(status: Set["active"]) }
  let(:q_status_b) { query(status: Set["blocked"]) }
  let(:q_value_1_10) { query(value: (1..10)) }
  let(:q_value_5_15) { query(value: (5..15)) }

  describe ".[] constructor" do
    it "returns ANYTHING for empty operands" do
      expect(described_class[]).to be(INatGet::Data::DSL::ANYTHING)
    end

    it "returns NOTHING if any operand is NOTHING" do
      expect(described_class[q1, INatGet::Data::DSL::NOTHING]).to be(INatGet::Data::DSL::NOTHING)
      expect(described_class[INatGet::Data::DSL::NOTHING, q1]).to be(INatGet::Data::DSL::NOTHING)
    end

    it "removes ANYTHING from operands" do
      result = described_class[q1, INatGet::Data::DSL::ANYTHING, q2]
      expect(result.operands).to contain_exactly(q1, q2)
    end

    it "returns frozen instance" do
      result = described_class[q1, q2]
      expect(result).to be_frozen
    end
  end

  describe "#& operator" do
    it "flattens nested AND" do
      inner = described_class[q1, q2]
      outer = inner & q3

      expect(outer).to be_a(described_class)
      expect(outer.operands.size).to eq(3)
      expect(outer.operands).to contain_exactly(q1, q2, q3)
    end

    it "flattens when other is also AND" do
      and1 = described_class[q1, q2]
      and2 = described_class[q3, q_status_a]
      result = and1 & and2

      expect(result.operands.size).to eq(4)
      expect(result.operands).to contain_exactly(q1, q2, q3, q_status_a)
    end

    it "creates new AND with single operand when other is not AND" do
      result = q1 & q2
      expect(result).to be_a(described_class)
      expect(result.operands).to contain_exactly(q1, q2)
    end
  end

  describe "#==" do
    it "is reflexive" do
      and_cond = described_class[q1, q2]
      expect(and_cond).to eq(and_cond)
    end

    it "ignores operand order" do
      a = described_class[q1, q2]
      b = described_class[q2, q1]
      expect(a).to eq(b)
    end

    it "returns false for different operands" do
      a = described_class[q1, q2]
      b = described_class[q2, q3]
      expect(a).not_to eq(b)
    end

    it "returns false for different types" do
      and_cond = described_class[q1, q2]
      or_cond = INatGet::Data::DSL::Condition::OR[q1, q2]
      expect(and_cond).not_to eq(or_cond)
    end

    it "returns false for nil" do
      expect(described_class[q1, q2]).not_to eq(nil)
    end
  end

  describe "#model" do
    it "returns model from first operand with non-nil model" do
      and_cond = described_class[q1, q2]
      expect(and_cond.model).to eq(q1.model)
    end
  end

  describe "#flatten" do
    it "flattens nested ANDs" do
      nested = described_class[q1, described_class[q2, q3]]
      flat = nested.flatten

      expect(flat).to be_a(described_class)
      expect(flat.operands.size).to eq(3)
      expect(flat.operands).to contain_exactly(q1, q2, q3)
    end

    it "flattens deeply nested ANDs" do
      deep = described_class[q1, described_class[q2, described_class[q3, q_status_a]]]
      flat = deep.flatten

      expect(flat.operands.size).to eq(4)
    end
  end

  describe "#expand_references" do
    it "expands references in all operands" do
      and_cond = described_class[q1, q2]
      expanded = and_cond.expand_references

      expect(expanded).to be_a(described_class)
      expect(expanded.operands.size).to eq(2)
    end
  end

  describe "#push_not_down" do
    it "passes through when no NOT operands" do
      and_cond = described_class[q1, q2]
      result = and_cond.push_not_down

      expect(result).to be_a(described_class)
      expect(result.operands).to contain_exactly(q1, q2)
    end
  end

  describe "#push_and_down" do
    it "distributes AND over OR (De Morgan-like)" do
      or_operand = INatGet::Data::DSL::Condition::OR[q2, q3]
      and_cond = described_class[q1, or_operand]

      result = and_cond.push_and_down

      # Should become OR[AND[q1,q2], AND[q1,q3]]
      expect(result).to be_a(INatGet::Data::DSL::Condition::OR)
      expect(result.operands.size).to eq(2)
      expect(result.operands.all? { |o| o.is_a?(described_class) }).to be true
    end

    it "passes through when no OR operands" do
      and_cond = described_class[q1, q2]
      result = and_cond.push_and_down

      expect(result).to be_a(described_class)
      expect(result.operands).to contain_exactly(q1, q2)
    end
  end

  describe "#merge_n_factor" do
    context "with Query operands" do
      it "merges compatible Query conditions" do
        q_a = query(id: Set[1, 2, 3])
        q_b = query(id: Set[2, 3, 4])
        and_cond = described_class[q_a, q_b]

        result = and_cond.merge_n_factor

        # Should merge to single Query with intersection
        expect(result).to be_a(INatGet::Data::DSL::Condition::Query)
        expect(result.query[:id]).to eq(Set[2, 3])
      end

      it "returns NOTHING for conflicting conditions" do
        q_a = query(id: Set[1])
        q_b = query(id: Set[2])
        and_cond = described_class[q_a, q_b]

        result = and_cond.merge_n_factor

        expect(result).to be(INatGet::Data::DSL::NOTHING)
      end

      it "keeps non-Query operands separate" do
        not_q = INatGet::Data::DSL::Condition::NOT[q1]
        and_cond = described_class[q2, not_q]

        result = and_cond.merge_n_factor

        expect(result).to be_a(described_class)
        expect(result.operands.size).to be >= 2
      end
    end

    context "with NOT operands" do
      it "merges NOT operands into single NOT-OR" do
        not1 = INatGet::Data::DSL::Condition::NOT[q1]
        not2 = INatGet::Data::DSL::Condition::NOT[q2]
        and_cond = described_class[q3, not1, not2]

        result = and_cond.merge_n_factor

        # Should have NOT[OR[q1, q2]] structure
        expect(result).to be_a(described_class)
      end

      it "returns NOTHING when NOT conflicts with Query" do
        not_q = INatGet::Data::DSL::Condition::NOT[q1]
        and_cond = described_class[q1, not_q]

        result = and_cond.merge_n_factor

        expect(result).to be(INatGet::Data::DSL::NOTHING)
      end
    end
  end

  describe "#simplify" do
    it "simplifies nested structure" do
      and_cond = described_class[q1, q2]
      result = and_cond.simplify

      expect(result).to be_a(INatGet::Data::DSL::Condition)
    end
  end

  describe "#to_sequel" do
    it "combines operands with AND" do
      and_cond = described_class[q1, q2]
      sequel = and_cond.to_sequel

      expect(sequel).to be_a(Sequel::SQL::BooleanExpression)
    end

    it "handles single operand" do
      and_cond = described_class[q1]
      sequel = and_cond.to_sequel

      expect(sequel).to be_a(Sequel::SQL::Expression)
    end
  end

  describe "#normalize" do
    it "executes full transformation chain" do
      and_cond = described_class[q1, q2]
      result = and_cond.normalize

      expect(result).to be_a(INatGet::Data::DSL::Condition)
      # normalize вызывает цепочку: expand_references.flatten.push_not_down.flatten.push_and_down.flatten.merge_n_factor.flatten
    end
  end

  describe "#api_query" do
    it "returns array of API requests" do
      and_cond = described_class[q1, q2]
      result = and_cond.api_query

      expect(result).to be_an(Array)
    end
  end

  describe "#sequel_query" do
    it "returns Sequel expression" do
      and_cond = described_class[q1, q2]
      result = and_cond.sequel_query

      expect(result).to be_a(Sequel::LiteralString)
    end
  end
end

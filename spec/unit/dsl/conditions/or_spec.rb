# frozen_string_literal: true

require "sequel"
require "spec_helper"
require "support/condition_test_helpers"

require_relative "../../../../lib/inat-get/data/dsl/conditions/base"
require_relative "../../../../lib/inat-get/data/dsl/conditions/and"
require_relative "../../../../lib/inat-get/data/dsl/conditions/or"
require_relative "../../../../lib/inat-get/data/dsl/conditions/not"
require_relative "../../../../lib/inat-get/data/dsl/conditions/query"

RSpec.describe INatGet::Data::DSL::Condition::OR do
  include ConditionTestHelpers

  let(:q1) { query(id: 1) }
  let(:q2) { query(id: 2) }
  let(:q3) { query(id: 3) }
  let(:q_status_a) { query(status: Set["active"]) }
  let(:q_status_b) { query(status: Set["blocked"]) }
  let(:q_value_1_10) { query(value: (1..10)) }
  let(:q_value_5_15) { query(value: (5..15)) }
  let(:q_value_20_30) { query(value: (20..30)) }

  describe ".[] constructor" do
    it "returns NOTHING for empty operands" do
      expect(described_class[]).to be(INatGet::Data::DSL::NOTHING)
    end

    it "returns ANYTHING if any operand is ANYTHING" do
      expect(described_class[q1, INatGet::Data::DSL::ANYTHING]).to be(INatGet::Data::DSL::ANYTHING)
      expect(described_class[INatGet::Data::DSL::ANYTHING, q1]).to be(INatGet::Data::DSL::ANYTHING)
    end

    it "removes NOTHING from operands" do
      result = described_class[q1, INatGet::Data::DSL::NOTHING, q2]
      expect(result.operands).to contain_exactly(q1, q2)
    end

    it "returns frozen instance" do
      result = described_class[q1, q2]
      expect(result).to be_frozen
    end
  end

  describe "#| operator" do
    it "flattens nested OR" do
      inner = described_class[q1, q2]
      outer = inner | q3

      expect(outer).to be_a(described_class)
      expect(outer.operands.size).to eq(3)
      expect(outer.operands).to contain_exactly(q1, q2, q3)
    end

    it "flattens when other is also OR" do
      or1 = described_class[q1, q2]
      or2 = described_class[q3, q_status_a]
      result = or1 | or2

      expect(result.operands.size).to eq(4)
      expect(result.operands).to contain_exactly(q1, q2, q3, q_status_a)
    end

    it "creates new OR with single operand when other is not OR" do
      result = q1 | q2
      expect(result).to be_a(described_class)
      expect(result.operands).to contain_exactly(q1, q2)
    end
  end

  describe "#==" do
    it "is reflexive" do
      or_cond = described_class[q1, q2]
      expect(or_cond).to eq(or_cond)
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
      or_cond = described_class[q1, q2]
      and_cond = INatGet::Data::DSL::Condition::AND[q1, q2]
      expect(or_cond).not_to eq(and_cond)
    end

    it "returns false for nil" do
      expect(described_class[q1, q2]).not_to eq(nil)
    end
  end

  describe "#model" do
    it "returns model from first operand with non-nil model" do
      or_cond = described_class[q1, q2]
      expect(or_cond.model).to eq(q1.model)
    end
  end

  describe "#flatten" do
    it "flattens nested ORs" do
      nested = described_class[q1, described_class[q2, q3]]
      flat = nested.flatten

      expect(flat).to be_a(described_class)
      expect(flat.operands.size).to eq(3)
      expect(flat.operands).to contain_exactly(q1, q2, q3)
    end

    it "flattens deeply nested ORs" do
      deep = described_class[q1, described_class[q2, described_class[q3, q_status_a]]]
      flat = deep.flatten

      expect(flat.operands.size).to eq(4)
    end
  end

  describe "#expand_references" do
    it "expands references in all operands" do
      or_cond = described_class[q1, q2]
      expanded = or_cond.expand_references

      expect(expanded).to be_a(described_class)
      expect(expanded.operands.size).to eq(2)
    end
  end

  describe "#push_not_down" do
    it "passes through when no NOT operands" do
      or_cond = described_class[q1, q2]
      result = or_cond.push_not_down

      expect(result).to be_a(described_class)
      expect(result.operands).to contain_exactly(q1, q2)
    end
  end

  describe "#push_and_down" do
    it "passes through (no distribution)" do
      or_cond = described_class[q1, q2]
      result = or_cond.push_and_down

      expect(result).to be_a(described_class)
      expect(result.operands).to contain_exactly(q1, q2)
    end
  end

  describe "#merge_n_factor" do
    context "with Query operands" do
      it "merges compatible Query conditions with Set values" do
        q_a = query(id: Set[1, 2])
        q_b = query(id: Set[3, 4])
        or_cond = described_class[q_a, q_b]

        result = or_cond.merge_n_factor

        # Should merge to single Query with union
        expect(result).to be_a(INatGet::Data::DSL::Condition::Query)
        expect(result.query[:id]).to eq(Set[1, 2, 3, 4])
      end

      it "keeps non-Query operands separate" do
        not_q = INatGet::Data::DSL::Condition::NOT[q1]
        or_cond = described_class[q2, not_q]

        result = or_cond.merge_n_factor

        expect(result).to be_a(described_class)
      end

      it "returns ANYTHING when NOT covers Query" do
        not_q = INatGet::Data::DSL::Condition::NOT[q1]
        or_cond = described_class[q1, not_q]

        result = or_cond.merge_n_factor

        expect(result).to be(INatGet::Data::DSL::ANYTHING)
      end
    end
  end

  describe "#simplify" do
    it "simplifies nested structure" do
      or_cond = described_class[q1, q2]
      result = or_cond.simplify

      expect(result).to be_a(INatGet::Data::DSL::Condition)
    end
  end

  describe "#to_sequel" do
    it "combines operands with OR" do
      or_cond = described_class[q1, q2]
      sequel = or_cond.to_sequel

      expect(sequel).to be_a(Sequel::SQL::BooleanExpression)
    end

    it "handles single operand" do
      or_cond = described_class[q1]
      sequel = or_cond.to_sequel

      expect(sequel).to be_a(Sequel::SQL::Expression)
    end
  end

  describe "#to_api" do
    it "returns array of API requests from all operands" do
      or_cond = described_class[q1, q2]
      result = or_cond.to_api

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
    end
  end

  describe "#normalize" do
    it "executes full transformation chain" do
      or_cond = described_class[q1, q2]
      result = or_cond.normalize

      expect(result).to be_a(INatGet::Data::DSL::Condition)
    end
  end

  describe "#api_query" do
    it "returns array of API requests" do
      or_cond = described_class[q1, q2]
      result = or_cond.api_query

      expect(result).to be_an(Array)
    end
  end

  describe "#sequel_query" do
    it "returns Sequel expression" do
      or_cond = described_class[q1, q2]
      result = or_cond.sequel_query

      expect(result).to be_a(Sequel::SQL::Expression)
    end
  end

  describe "private #hash_cover?" do
    # Тестируем через merge_n_factor поведение
    context "condition coverage detection" do
      it "detects when one Set covers another" do
        q_cover = query(id: Set[1, 2, 3, 4, 5])
        q_covered = query(id: Set[2, 3])
        or_cond = described_class[q_cover, q_covered]

        result = or_cond.merge_n_factor

        # q_covered is covered by q_cover, so result should be just q_cover
        expect(result).to be_a(INatGet::Data::DSL::Condition::Query)
        expect(result.query[:id]).to eq(Set[1, 2, 3, 4, 5])
      end

      it "detects when one Range covers another" do
        q_cover = query(value: (1..20))
        q_covered = query(value: (5..10))
        or_cond = described_class[q_cover, q_covered]

        result = or_cond.merge_n_factor

        expect(result).to be_a(INatGet::Data::DSL::Condition::Query)
        expect(result.query[:value]).to eq((1..20))
      end
    end
  end

  describe "private #hash_try_merge" do
    context "condition merging" do
      it "merges adjacent Set values" do
        q_a = query(id: Set[1, 2])
        q_b = query(id: Set[3, 4])
        or_cond = described_class[q_a, q_b]

        result = or_cond.merge_n_factor

        expect(result.query[:id]).to eq(Set[1, 2, 3, 4])
      end

      it "merges adjacent Range values" do
        q_a = query(value: (1..10))
        q_b = query(value: (11..20))
        or_cond = described_class[q_a, q_b]

        result = or_cond.merge_n_factor

        expect(result.query[:value]).to eq((1..20))
      end

      it "merges Set and single value into larger Set" do
        q_set = query(id: Set[1, 2, 3])
        q_single = query(id: 4)
        or_cond = described_class[q_set, q_single]

        result = or_cond.merge_n_factor

        expect(result.query[:id]).to eq(Set[1, 2, 3, 4])
      end

      it "does not merge non-adjacent Ranges" do
        q_a = query(value: (1..5))
        q_b = query(value: (10..15))
        or_cond = described_class[q_a, q_b]

        result = or_cond.merge_n_factor

        # Should remain as OR since ranges don't overlap or touch
        expect(result).to be_a(described_class)
      end
    end
  end
end

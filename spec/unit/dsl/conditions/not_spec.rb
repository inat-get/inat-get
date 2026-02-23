# frozen_string_literal: true

require "sequel"
require "spec_helper"
require "support/condition_test_helpers"

require_relative "../../../../lib/inat-get/data/dsl/conditions/base"
require_relative "../../../../lib/inat-get/data/dsl/conditions/and"
require_relative "../../../../lib/inat-get/data/dsl/conditions/or"
require_relative "../../../../lib/inat-get/data/dsl/conditions/not"
require_relative "../../../../lib/inat-get/data/dsl/conditions/query"

RSpec.describe INatGet::Data::DSL::Condition::NOT do
  include ConditionTestHelpers

  let(:q1) { query(id: 1) }
  let(:q2) { query(id: 2) }
  let(:q3) { query(id: 3) }
  let(:and_cond) { INatGet::Data::DSL::Condition::AND[q1, q2] }
  let(:or_cond) { INatGet::Data::DSL::Condition::OR[q1, q2] }

  describe ".[] constructor" do
    it "returns ANYTHING for NOTHING operand" do
      result = described_class[INatGet::Data::DSL::NOTHING]
      expect(result).to be(INatGet::Data::DSL::ANYTHING)
    end

    it "returns NOTHING for ANYTHING operand" do
      result = described_class[INatGet::Data::DSL::ANYTHING]
      expect(result).to be(INatGet::Data::DSL::NOTHING)
    end

    it "unwraps double negation" do
      inner = described_class[q1]
      result = described_class[inner]

      expect(result).to eq(q1)
    end

    it "creates new NOT for regular operand" do
      result = described_class[q1]

      expect(result).to be_a(described_class)
      expect(result.operand).to eq(q1)
      expect(result).to be_frozen
    end
  end

  describe "#operand" do
    it "returns the wrapped operand" do
      not_cond = described_class[q1]
      expect(not_cond.operand).to eq(q1)
    end
  end

  describe "#model" do
    it "returns model from operand" do
      not_cond = described_class[q1]
      expect(not_cond.model).to eq(q1.model)
    end
  end

  describe "#& operator" do
    it "returns NOTHING when operand equals other" do
      not_cond = described_class[q1]
      result = not_cond & q1

      expect(result).to be(INatGet::Data::DSL::NOTHING)
    end

    it "returns AND when operand differs from other" do
      not_cond = described_class[q1]
      result = not_cond & q2

      expect(result).to be_a(INatGet::Data::DSL::Condition::AND)
      expect(result.operands).to contain_exactly(not_cond, q2)
    end
  end

  describe "#| operator" do
    it "returns ANYTHING when operand equals other" do
      not_cond = described_class[q1]
      result = not_cond | q1

      expect(result).to be(INatGet::Data::DSL::ANYTHING)
    end

    it "returns OR when operand differs from other" do
      not_cond = described_class[q1]
      result = not_cond | q2

      expect(result).to be_a(INatGet::Data::DSL::Condition::OR)
      expect(result.operands).to contain_exactly(not_cond, q2)
    end
  end

  describe "#! operator (negation)" do
    it "returns the original operand" do
      not_cond = described_class[q1]
      result = !not_cond

      expect(result).to eq(q1)
    end

    it "double negation returns equivalent of original" do
      not_not = described_class[described_class[q1]]
      result = !not_not

      expect(result).to be_a(described_class)
      expect(result.operand).to eq(q1)
    end
  end

  describe "#==" do
    it "is reflexive" do
      not_cond = described_class[q1]
      expect(not_cond).to eq(not_cond)
    end

    it "returns true for same operand" do
      a = described_class[q1]
      b = described_class[q1]
      expect(a).to eq(b)
    end

    it "returns false for different operands" do
      a = described_class[q1]
      b = described_class[q2]
      expect(a).not_to eq(b)
    end

    it "returns false for different types" do
      not_cond = described_class[q1]
      and_cond = INatGet::Data::DSL::Condition::AND[q1, q2]
      expect(not_cond).not_to eq(and_cond)
    end

    it "returns false for nil" do
      expect(described_class[q1]).not_to eq(nil)
    end
  end

  describe "#flatten" do
    it "unwraps double negation" do
      inner = described_class[q1]
      not_not = described_class[inner]
      flat = not_not.flatten

      expect(flat).to eq(q1)
    end

    it "returns NOT with flattened operand" do
      not_cond = described_class[q1]
      flat = not_cond.flatten

      expect(flat).to be_a(described_class)
      expect(flat.operand).to eq(q1)
    end
  end

  describe "#expand_references" do
    it "expands references in operand" do
      not_cond = described_class[q1]
      expanded = not_cond.expand_references

      expect(expanded).to be_a(described_class)
      expect(expanded.operand).to be_a(INatGet::Data::DSL::Condition::Query)
    end
  end

  describe "#push_not_down (De Morgan's laws)" do
    it "transforms NOT[AND] to OR[NOTs]" do
      not_and = described_class[and_cond]
      result = not_and.push_not_down

      expect(result).to be_a(INatGet::Data::DSL::Condition::OR)
      expect(result.operands.size).to eq(2)
      expect(result.operands.all? { |o| o.is_a?(described_class) }).to be true
    end

    it "transforms NOT[OR] to AND[NOTs]" do
      not_or = described_class[or_cond]
      result = not_or.push_not_down

      expect(result).to be_a(INatGet::Data::DSL::Condition::AND)
      expect(result.operands.size).to eq(2)
      expect(result.operands.all? { |o| o.is_a?(described_class) }).to be true
    end

    it "unwraps NOT[NOT]" do
      not_not = described_class[described_class[q1]]
      result = not_not.push_not_down

      expect(result).to eq(q1)
    end

    it "passes through for Query operand" do
      not_q = described_class[q1]
      result = not_q.push_not_down

      expect(result).to be_a(described_class)
      expect(result.operand).to eq(q1)
    end
  end

  describe "#merge_n_factor" do
    it "delegates to operand and wraps result" do
      not_q = described_class[q1]
      result = not_q.merge_n_factor

      expect(result).to be_a(described_class)
      expect(result.operand).to eq(q1.merge_n_factor)
    end
  end

  describe "#simplify" do
    it "returns ANYTHING (simplification of NOT)" do
      not_q = described_class[q1]
      result = not_q.simplify

      expect(result).to be(INatGet::Data::DSL::ANYTHING)
    end
  end

  describe "#to_sequel" do
    it "returns negated Sequel expression" do
      not_q = described_class[q1]
      sequel = not_q.to_sequel

      expect(sequel).to be_a(Sequel::SQL::BooleanExpression)
    end
  end

  describe "#normalize" do
    it "executes full transformation chain" do
      not_q = described_class[q1]
      result = not_q.normalize

      expect(result).to be_a(INatGet::Data::DSL::Condition)
    end
  end

  describe "#api_query" do
    it "raises error (NOT cannot be directly translated to API)" do
      not_q = described_class[q1]

      expect { not_q.api_query }.to raise_error(TypeError)
    end
  end

  describe "#sequel_query" do
    it "returns Sequel expression" do
      not_q = described_class[q1]
      result = not_q.sequel_query

      expect(result).to be_a(Sequel::SQL::Expression)
    end
  end
end

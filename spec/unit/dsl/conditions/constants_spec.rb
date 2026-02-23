# frozen_string_literal: true

require "sequel"
require "spec_helper"
require "support/condition_test_helpers"

require_relative "../../../../lib/inat-get/data/dsl/conditions/base"
require_relative "../../../../lib/inat-get/data/dsl/conditions/and"
require_relative "../../../../lib/inat-get/data/dsl/conditions/or"
require_relative "../../../../lib/inat-get/data/dsl/conditions/not"
require_relative "../../../../lib/inat-get/data/dsl/conditions/query"

RSpec.describe "Condition constants" do
  include ConditionTestHelpers

  let(:q1) { query(id: 1) }
  let(:q2) { query(id: 2) }
  let(:anything) { INatGet::Data::DSL::ANYTHING }
  let(:nothing) { INatGet::Data::DSL::NOTHING }

  describe "ANYTHING" do
    describe "#& (AND)" do
      it "returns other operand" do
        expect(anything & q1).to eq(q1)
        expect(q1 & anything).to eq(q1)
      end

      it "returns ANYTHING when other is ANYTHING" do
        expect(anything & anything).to be(anything)
      end

      it "returns NOTHING when other is NOTHING" do
        expect(anything & nothing).to be(nothing)
        expect(nothing & anything).to be(nothing)
      end
    end

    describe "#| (OR)" do
      it "returns ANYTHING" do
        expect(anything | q1).to be(anything)
        expect(q1 | anything).to be(anything)
        expect(anything | anything).to be(anything)
      end

      it "returns ANYTHING when other is NOTHING" do
        expect(anything | nothing).to be(anything)
        expect(nothing | anything).to be(anything)
      end
    end

    describe "#! (NOT)" do
      it "returns NOTHING" do
        expect(!anything).to be(nothing)
      end
    end

    describe "#to_sequel" do
      it "returns true literal" do
        result = anything.to_sequel
        expect(result).to be_a(Sequel::LiteralString)
        # Sequel.lit('true') создает ComplexExpression
      end
    end

    describe "singleton behavior" do
      it "is same instance" do
        expect(INatGet::Data::DSL::ANYTHING).to be(anything)
      end

      it "is frozen" do
        expect(anything).to be_frozen
      end
    end
  end

  describe "NOTHING" do
    describe "#& (AND)" do
      it "returns NOTHING" do
        expect(nothing & q1).to be(nothing)
        expect(q1 & nothing).to be(nothing)
        expect(nothing & nothing).to be(nothing)
      end

      it "returns NOTHING when other is ANYTHING" do
        expect(nothing & anything).to be(nothing)
      end
    end

    describe "#| (OR)" do
      it "returns other operand" do
        expect(nothing | q1).to eq(q1)
        expect(q1 | nothing).to eq(q1)
      end

      it "returns ANYTHING when other is ANYTHING" do
        expect(nothing | anything).to be(anything)
        expect(anything | nothing).to be(anything)
      end

      it "returns NOTHING when other is NOTHING" do
        expect(nothing | nothing).to be(nothing)
      end
    end

    describe "#! (NOT)" do
      it "returns ANYTHING" do
        expect(!nothing).to be(anything)
      end
    end

    describe "#to_sequel" do
      it "returns false literal" do
        result = nothing.to_sequel
        expect(result).to be_a(Sequel::LiteralString)
      end
    end

    describe "#to_api" do
      it "returns empty array" do
        expect(nothing.to_api).to eq([])
      end
    end

    describe "singleton behavior" do
      it "is same instance" do
        expect(INatGet::Data::DSL::NOTHING).to be(nothing)
      end

      it "is frozen" do
        expect(nothing).to be_frozen
      end
    end
  end

  describe "interaction between constants and complex conditions" do
    it "AND with ANYTHING flattens correctly" do
      and_cond = INatGet::Data::DSL::Condition::AND[q1, q2]
      result = and_cond & anything
      expect(result).to eq(and_cond)
    end

    it "OR with NOTHING flattens correctly" do
      or_cond = INatGet::Data::DSL::Condition::OR[q1, q2]
      result = or_cond | nothing
      expect(result).to eq(or_cond)
    end

    it "AND constructor filters out ANYTHING" do
      result = INatGet::Data::DSL::Condition::AND[q1, anything, q2]
      expect(result.operands).to contain_exactly(q1, q2)
    end

    it "OR constructor filters out NOTHING" do
      result = INatGet::Data::DSL::Condition::OR[q1, nothing, q2]
      expect(result.operands).to contain_exactly(q1, q2)
    end
  end
end

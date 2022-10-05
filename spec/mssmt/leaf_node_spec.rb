# frozen_string_literal: true

require "spec_helper"

RSpec.describe MSSMT::LeafNode do
  describe "#node_hash" do
    subject(:node_hash) { node.node_hash.unpack1("H*") }

    context "with empty leaf" do
      let(:node) { described_class.empty_leaf }

      it "return hash value" do
        # empty leaf
        expect(node_hash).to eq(
          "af5570f5a1810b7af78caf4bc70a660f0df51e42baf91d4de5b2328de0e83dfc"
        )
      end
    end

    context "with not empty sum" do
      let(:node) { described_class.new(nil, 3) }

      it "return hash value" do
        expect(node_hash).to eq(
          "d5688a52d55a02ec4aea5ec1eadfffe1c9e0ee6a4ddbe2377f98326d42dfc975"
        )
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe MSSMT::Tree::Simple do
  describe "#root_hash" do
    context "with empty tree" do
      it do
        expect(described_class.empty_tree.root_hash.unpack1("H*")).to eq(
          "b1e8e8f2dc3b266452988cfe169aa73be25405eeead02ab5dd6b3c6fd0ca8d67"
        )
      end
    end
  end
end

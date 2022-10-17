# frozen_string_literal: true

require "spec_helper"

RSpec.describe MSSMT::Tree do
  describe "#root_hash" do
    context "with empty tree" do
      it do
        expect(described_class.new.root_hash.unpack1("H*")).to eq(
          "b1e8e8f2dc3b266452988cfe169aa73be25405eeead02ab5dd6b3c6fd0ca8d67"
        )
      end
    end
  end

  describe "#insert" do
    it do
      tree = described_class.new
      leaves = load_leaves
      leaves.each { |key, leaf| tree.insert(key, leaf) }
      expect(tree.root_hash.unpack1("H*")).to eq(
        "b4ba2dcbdedd58a41eb85f488646a4276ffcee62d2645aa087666b51b98c7d9d"
      )
      leaves.each do |key, leaf|
        expect(tree.get(key).node_hash).to eq(leaf.node_hash)
      end
      # Specify random key, it return empty leaf.
      leaf = tree.get(Random.bytes(32).unpack1("H*"))
      expect(leaf.empty?).to be true
    end
  end

  describe "#delete" do
    it do
      tree = described_class.new
      leaves = load_leaves
      leaves.each { |key, leaf| tree.insert(key, leaf) }
      # rubocop:disable Style/CombinableLoops
      leaves.each do |key, _|
        tree.delete(key)
        expect(tree.get(key).empty?).to be true
      end
      # rubocop:enable Style/CombinableLoops
      expect(tree.root_hash).to eq(tree.empty_tree[0].node_hash)
    end
  end

  describe "#merkle_proof" do
    it do
      tree = described_class.new
      leaves = load_leaves
      leaves.each { |key, leaf| tree.insert(key, leaf) }
      # rubocop:disable Style/CombinableLoops
      leaves.each do |key, leaf|
        proof = tree.merkle_proof(key)
        expect(tree.valid_merkle_proof?(key, leaf, proof)).to be true
        # If e alter the proof's leaf sum, then the proof should no longer be valid.
        altered_leaf = MSSMT::LeafNode.new(leaf.value, leaf.sum + 1)
        expect(tree.valid_merkle_proof?(key, altered_leaf, proof)).to be false
        # If e delete the proof's leaf node from the tree, then it should also no longer be valid.
        tree.delete(key)
        expect(tree.valid_merkle_proof?(key, leaf, proof)).to be false
      end
      # rubocop:enable Style/CombinableLoops
    end
  end

  def load_leaves
    csv =
      CSV.read(
        fixture_path(
          "b4ba2dcbdedd58a41eb85f488646a4276ffcee62d2645aa087666b51b98c7d9d.csv"
        )
      )
    csv[1..].map { |k, v, s| [k, MSSMT::LeafNode.new([v].pack("H*"), s.to_i)] }
  end
end

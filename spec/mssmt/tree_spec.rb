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
      root_hash =
        "ac5d459d070650fa031b61c8d1fa785352575a4234537b63953a21c4aba56bac"
      leaves = load_leaves("#{root_hash}.csv")
      leaves.each { |key, leaf| tree.insert(key, leaf) }
      expect(tree.root_hash.unpack1("H*")).to eq(root_hash)
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
      leaves = rand_leaves(1_000)
      leaves.each { |key, leaf| tree.insert(key, leaf) }
      # rubocop:disable Style/CombinableLoops
      leaves.each do |key, _|
        tree.delete(key)
        expect(tree.get(key).empty?).to be true
      end
      # rubocop:enable Style/CombinableLoops
      expect(tree.root_hash).to eq(described_class.empty_tree[0].node_hash)
    end
  end

  describe "#merkle_proof" do
    it do
      tree = described_class.new
      leaves = rand_leaves(1_000)
      leaves.each { |key, leaf| tree.insert(key, leaf) }
      # rubocop:disable Style/CombinableLoops
      leaves.each do |key, leaf|
        proof = tree.merkle_proof(key)
        expect(tree.valid_merkle_proof?(key, leaf, proof)).to be true
        compressed_proof = proof.compress
        expect(compressed_proof.decompress).to eq(proof)
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

  describe "max sum value" do
    context "with within max sum value" do
      it do
        tree = described_class.new
        leaf1 = MSSMT::LeafNode.new("", 0xfffffffffffffffe)
        tree.insert(Random.bytes(32).unpack1("H*"), leaf1)
        leaf2 = MSSMT::LeafNode.new("", 1)
        tree.insert(Random.bytes(32).unpack1("H*"), leaf2)
        expect(tree.root_node.sum).to eq(0xffffffffffffffff)
      end
    end

    context "with over max sum value" do
      it do
        tree = described_class.new
        leaf1 = MSSMT::LeafNode.new("", 0xfffffffffffffffe)
        tree.insert(Random.bytes(32).unpack1("H*"), leaf1)
        leaf2 = MSSMT::LeafNode.new("", 2)
        expect do
          tree.insert(Random.bytes(32).unpack1("H*"), leaf2)
        end.to raise_error(MSSMT::OverflowError)
        expect do
          MSSMT::LeafNode.new("", 0xffffffffffffffff + 1)
        end.to raise_error(MSSMT::OverflowError)
        expect do
          MSSMT::ComputedNode.new("", 0xffffffffffffffff + 1)
        end.to raise_error(MSSMT::OverflowError)
      end
    end
  end
end

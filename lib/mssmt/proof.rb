# frozen_string_literal: true
module MSSMT
  # Merkle proof for MS-SMT.
  class Proof
    attr_reader :nodes

    # Constructor
    # @param [Array(MSSMT::BranchNode|MSSMT::LeafNode)] nodes Siblings that should be hashed with the leaf and
    # its parents to arrive at the root of the MS-SMT.
    def initialize(nodes)
      @nodes = nodes
    end

    # Compresses a merkle proof by replacing its empty nodes with a bit vector.
    # @return [MSSMT::CompressedProof]
    def compress
      bits = Array.new(nodes.length, false)
      compact_nodes = []
      nodes.each.each_with_index do |node, i|
        # puts "#{node.node_hash}:#{Tree.empty_tree[Tree::MAX_LEVEL - 1].node_hash}"
        if node.node_hash == Tree.empty_tree[Tree::MAX_LEVEL - 1].node_hash
          bits[i] = true
        else
          compact_nodes << node
        end
      end
      CompressedProof.new(compact_nodes, bits)
    end

    def ==(other)
      return false unless other.is_a?(Proof)
      nodes == other.nodes
    end
  end

  # Compressed MS-SMT merkle proof.
  # Since merkle proofs for a MS-SMT are always constant size (255 nodes),
  # we replace its empty nodes by a bit vector.
  class CompressedProof < Proof
    attr_reader :bits

    # Constructor
    # @param [Array(MSSMT::BranchNode|MSSMT::LeafNode)] nodes Siblings that should be hashed with the leaf and
    # its parents to arrive at the root of the MS-SMT.
    # @param [Array] bits +bits+ determines whether a sibling node within a proof is part of the empty tree.
    # This allows us to efficiently compress proofs by not including any pre-computed nodes.
    def initialize(nodes, bits)
      super(nodes)
      @bits = bits
    end

    # Decompress a compressed merkle proof by replacing its bit vector with the empty nodes it represents.
    # @return [MSSMT::Proof]
    def decompress
      count = 0
      full_nodes = []
      bits.each.with_index do |b, i|
        if b
          full_nodes << Tree.empty_tree[Tree::MAX_LEVEL - i]
        else
          full_nodes << nodes[count]
          count += 1
        end
      end
      Proof.new(full_nodes)
    end
  end
end

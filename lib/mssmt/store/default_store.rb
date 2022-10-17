# frozen_string_literal: true

module MSSMT
  module Store
    # In-memory implementation of the tree store.
    class DefaultStore
      attr_accessor :branches, :leaves, :root

      def initialize
        @branches = {}
        @leaves = {}
        @root = nil
      end

      # Insert branch node.
      # @param [MSSMT::BranchNode] branch
      # @raise [ArgumentError]
      def insert_branch(branch)
        raise "branch must be MSSMT::BranchNode" unless branch.is_a?(MSSMT::BranchNode)

        branches[branch.node_hash] = branch
      end

      # Insert leaf node.
      # @param [MSSMT::LeafNode] leaf
      # @raise [ArgumentError]
      def insert_leaf(leaf)
        raise "leaf must be MSSMT::LeafNode" unless leaf.is_a?(MSSMT::LeafNode)

        leaves[leaf.node_hash] = leaf
      end

      # Delete branch node.
      # @param [String] node_hash node hash of branch node.
      def delete_branch(node_hash)
        branches.delete(node_hash)
      end

      # Delete leaf node
      # @param [String] node_hash node hash of leaf node.
      def delete_leaf(node_hash)
        leaves.delete(node_hash)
      end
    end
  end
end

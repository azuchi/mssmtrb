# frozen_string_literal: true

module MSSMT
  module Tree
    # This is a simple implementation of MS-SMT. Data for each node is not persisted.
    class Simple
      attr_reader :tree

      def initialize
        @tree = Array.new(MSSMT::Tree::MAX_LEVEL + 1)
        @tree[MSSMT::Tree::MAX_LEVEL] = MSSMT::LeafNode.empty_leaf
        MSSMT::Tree::MAX_LEVEL.times do |i|
          branch =
            MSSMT::BranchNode.new(
              @tree[MSSMT::Tree::MAX_LEVEL - i],
              @tree[MSSMT::Tree::MAX_LEVEL - i]
            )
          @tree[MSSMT::Tree::MAX_LEVEL - (i + 1)] = branch
        end
      end

      # Root hash of this tree
      # @return [String] root hash value.
      def root_hash
        tree[0].node_hash
      end
    end
  end
end

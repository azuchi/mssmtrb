# frozen_string_literal: true

module MSSMT
  # Intermediate or root node within a MS-SMT.
  class BranchNode
    attr_reader :left, :right, :node_hash, :sum

    def initialize(left, right)
      raise ArgumentError, "left must be a branch or leaf node" if !left.is_a?(BranchNode) && !left.is_a?(LeafNode)
      raise ArgumentError, "right must be a branch or leaf node" if !right.is_a?(BranchNode) && !right.is_a?(LeafNode)

      @left = left
      @right = right
      @sum = left.sum + right.sum
      @node_hash =
        Digest::SHA256.digest(
          "#{left.node_hash}#{right.node_hash}#{[@sum].pack("Q>")}"
        )
    end
  end
end

# frozen_string_literal: true

module MSSMT
  # Intermediate or root node within a MS-SMT.
  class BranchNode
    attr_reader :left, :right, :node_hash, :sum

    def initialize(left, right)
      if !left.is_a?(BranchNode) && !left.is_a?(LeafNode)
        raise ArgumentError, "left must be a branch or leaf node"
      end
      if !right.is_a?(BranchNode) && !right.is_a?(LeafNode)
        raise ArgumentError, "right must be a branch or leaf node"
      end

      @left = left
      @right = right
      @sum = left.sum + right.sum
      warn("sum:#{@sum} cause overflow.") if @sum > 0xffffffffffffffff # TODO
      @sum = (@sum & 0xffffffffffffffff)
      @node_hash =
        Digest::SHA256.digest(
          "#{left.node_hash}#{right.node_hash}#{[@sum].pack("Q>")}"
        )
    end

    # Check whether same branch|computed node or not.
    # @return [Boolean]
    def ==(other)
      return false unless [BranchNode, ComputedNode].include?(other.class)
      node_hash == other.node_hash && sum == other.sum
    end
  end
end

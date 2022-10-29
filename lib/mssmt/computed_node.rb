# frozen_string_literal: true

module MSSMT
  # Node within a MS-SMT that has already had its node_hash and sum computed, i.e., its preimage is not available.
  class ComputedNode
    attr_reader :node_hash, :sum

    # Constructor
    # @param [String] node_hash node hash with binary fomat.
    # @param [Integer] sum
    def initialize(node_hash, sum)
      @node_hash = node_hash
      warn("sum: #{sum} cause overflow.") if sum > 0xffffffffffffffff # TODO
      @sum = sum
    end

    def ==(other)
      return false unless [BranchNode, ComputedNode].include?(other.class)
      node_hash == other.node_hash && sum == other.sum
    end
  end
end

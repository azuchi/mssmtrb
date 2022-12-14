# frozen_string_literal: true

module MSSMT
  # Leaf node within a MS-SMT that commit to a value and some integer value (the sum) associated with the value.
  class LeafNode
    attr_reader :value, :sum

    # Constructor
    # @param [String] value node value with binary format.
    # @param [Integer] sum integer value associated with the value
    # @raise [MSSMT::OverflowError]
    def initialize(value, sum)
      @value = value
      if sum > Tree::MAX_SUM_VALUE
        raise OverflowError, "sum: #{sum} is overflow"
      end
      @sum = sum
    end

    # Generate empty leaf node.
    # @return [MSSMT::LeafNode]
    def self.empty_leaf
      LeafNode.new(nil, 0)
    end

    # Calculate node hash.
    # @return [String] hash value.
    def node_hash
      Digest::SHA256.digest("#{value}#{[sum].pack("Q>")}")
    end

    # Check whether value and sum is empty.
    # @return [Boolean]
    def empty?
      (value.nil? or value.empty?) && sum.zero?
    end

    def ==(other)
      return false unless other.is_a?(LeafNode)
      node_hash == other.node_hash
    end
  end
end

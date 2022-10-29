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
        if node.node_hash == Tree.empty_tree[Tree::MAX_LEVEL - i].node_hash
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

    # Decode compressed proof.
    # @param [String] compressed proof with binary fomat.
    # @return [MSSMT::CompressedProof]
    def self.decode(data)
      buf = data.is_a?(StringIO) ? data : StringIO.new(data)
      nodes_len = buf.read(2).unpack1("n")
      nodes =
        nodes_len.times.map do
          ComputedNode.new(buf.read(32), buf.read(8).unpack1("Q>"))
        end
      bytes = buf.read(MSSMT::Tree::MAX_LEVEL / 8)
      bits = unpack_bits(bytes.unpack("C*"))
      CompressedProof.new(nodes, bits)
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

    # Encode the compressed proof.
    # @return [String] encoded string.
    def encode
      buf = [nodes.length].pack("n")
      nodes.each do |node|
        buf << node.node_hash
        buf << [node.sum].pack("Q>")
      end
      buf << pack_bits.pack("C*")
      buf
    end

    def ==(other)
      return false unless other.is_a?(CompressedProof)
      bits == other.bits && nodes == other.nodes
    end

    private

    def pack_bits
      bytes = Array.new((bits.length + 8 - 1) / 8, 0)
      bits.each_with_index do |b, i|
        next unless b
        byte_index = i / 8
        bit_index = i % 8
        bytes[byte_index] |= (1 << bit_index)
      end
      bytes
    end

    def self.unpack_bits(bytes)
      bit_len = bytes.length * 8
      bits = Array.new(bit_len, false)
      bit_len.times do |i|
        byte_index = i / 8
        bit_index = i % 8
        bits[i] = ((bytes[byte_index] >> bit_index) & 1) == 1
      end
      bits
    end

    private_class_method :unpack_bits
  end
end

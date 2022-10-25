# frozen_string_literal: true
module MSSMT
  # Merkle proof for MS-SMT.
  class Proof
    attr_reader :nodes

    def initialize(nodes)
      @nodes = nodes
    end
  end

  # Compressed MS-SMT merkle proof.
  # Since merkle proofs for a MS-SMT are always constant size (255 nodes),
  # we replace its empty nodes by a bit vector.
  class CompressedProof < Proof
    attr_reader :bits

    def initialize(nodes, bits)
      super(nodes)
      @bits = bits
    end
  end
end

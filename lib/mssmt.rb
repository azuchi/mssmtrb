# frozen_string_literal: true

require "digest"
require_relative "mssmt/version"
require "stringio"

# Merkle Sum Sparse Merkle Tree
module MSSMT
  class Error < StandardError
  end

  # Error when sum overflows
  class OverflowError < Error
  end

  autoload :Store, "mssmt/store"
  autoload :LeafNode, "mssmt/leaf_node"
  autoload :BranchNode, "mssmt/branch_node"
  autoload :ComputedNode, "mssmt/computed_node"
  autoload :Tree, "mssmt/tree"
  autoload :Proof, "mssmt/proof"
  autoload :CompressedProof, "mssmt/proof"
end

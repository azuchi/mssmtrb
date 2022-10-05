# frozen_string_literal: true

require 'digest'
require_relative 'mssmt/version'

# Merkle Sum Sparse Merkle Tree
module MSSMT
  class Error < StandardError
  end

  autoload :LeafNode, 'mssmt/leaf_node'
end
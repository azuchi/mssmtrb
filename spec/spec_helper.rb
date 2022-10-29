# frozen_string_literal: true

require "mssmt"
require "csv"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_path(relative_path)
  File.join(File.dirname(__FILE__), "fixtures", relative_path)
end

# Generate random key.
# @return [String]
def rand_key
  Random.bytes(MSSMT::Tree::HASH_SIZE)
end

# Generate random leaf
# @return [MSSMT::LeafNode]
def rand_leaf
  sum = Random.rand(0xFFFFFFFFFFFFFFFF)
  value = Random.bytes(256)
  MSSMT::LeafNode.new(value, sum)
end

# Generate random leaves
# @return [Hash]
def rand_leaves(num)
  leaves = {}
  num.times { leaves[Random.bytes(32).unpack1("H*")] = rand_leaf }
  leaves
end

# load leaves csv composed by key, value, sum
def load_leaves(file_name)
  csv = CSV.read(fixture_path(file_name))
  csv[1..].map { |k, v, s| [k, MSSMT::LeafNode.new([v].pack("H*"), s.to_i)] }
end

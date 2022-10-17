# Merkle Sum Sparse Merkle Tree

This is the Merkle Sum Sparse Merkle Tree(MS-SMT) ruby library.
[MS-SMT](https://github.com/Roasbeef/bips/blob/bip-taro/bip-taro.mediawiki#MerkleSum_Sparse_Merkle_Trees) is a tree 
that combines the Sparse Merkle Tree and the Merkle-Sum Tree and is defined by the [Taro protocol](https://github.com/Roasbeef/bips/blob/bip-taro/bip-taro.mediawiki).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mssmt'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mssmt

## Usage

```ruby
require 'mssmt'

# initialize tree
tree = MSSMT::Tree.new

# Add leaf node to tree with key.
leaf = MSSMT::LeafNode.new("Data", 1_000)
key = "5bc565ef18dbe0636cd3398a870ae24e1f184e5c484e1af3a502f77a0aceb0c5"
tree.insert(key, leaf)

# Get root node
root_node = tree.root_node
# Root hash
root_hash = tree.root_hash.unpack1('H*')
# or
root_node.node_hash.unpack1('H*')

# Get leaf node in tree
leaf = tree.get(key)

# Get merkle proof correspond to key
proof = tree.merkle_proof(key)

# Check merkle proof validity.
result = tree.valid_merkle_proof?(key, leaf, proof)

# Delete leaf node
tree.delete(key)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mssmt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/mssmt/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mssmt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mssmt/blob/master/CODE_OF_CONDUCT.md).

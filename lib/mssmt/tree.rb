# frozen_string_literal: true

module MSSMT
  # MS-SMT tree
  class Tree
    # The size of a SHA256 checksum in bytes.
    HASH_SIZE = 32
    # Depth of the MS-SMT(using SHA256)
    MAX_LEVEL = HASH_SIZE * 8
    # Index of the last bit for MS-SMT keys
    LAST_BIT_INDEX = MAX_LEVEL - 1

    attr_reader :empty_tree, :store

    def initialize(store: MSSMT::Store::DefaultStore.new)
      @empty_tree = build_empty_tree
      @store = store
    end

    # Root hash of this tree
    # @return [String] root hash value.
    def root_hash
      root_node.node_hash
    end

    # Get root node in tree.
    # @return [MSSMT::BranchNode]
    def root_node
      store.root.nil? ? empty_tree[0] : store.root
    end

    # Insert a leaf node at the given key within the MS-SMT.
    # @param [String] key key with hex format.
    # @param [MSSMT::LeafNode] leaf leaf node.
    # @return [MSSMT::BranchNode] Updated root node.
    # @raise [MSSMT::Error]
    def insert(key, leaf)
      raise MSSMT::Error, "key must be #{HASH_SIZE} bytes" unless [key].pack("H*").bytesize == HASH_SIZE

      prev_parents = Array.new(MSSMT::Tree::MAX_LEVEL)
      siblings = Array.new(MSSMT::Tree::MAX_LEVEL)
      walk_down(key) do |i, _, sibling, parent|
        prev_parents[MSSMT::Tree::MAX_LEVEL - 1 - i] = parent.node_hash
        siblings[MSSMT::Tree::MAX_LEVEL - 1 - i] = sibling
      end

      root =
        walk_up(key, leaf, siblings) do |i, _, _, parent|
          prev_parent = prev_parents[MSSMT::Tree::MAX_LEVEL - 1 - i]
          store.delete_branch(prev_parent) unless prev_parent == empty_tree[i].node_hash
          store.insert_branch(parent) unless parent.node_hash == empty_tree[i].node_hash
        end

      leaf.empty? ? store.delete_leaf(key) : store.insert_leaf(leaf)
      store.root = root
    end

    # Delete the leaf node found at the given key within the MS-SMT.
    # @param [String] key
    def delete(key)
    end

    # Get leaf node found at the given key within the MS-SMT.
    # @param [String] key
    def get(key)
    end

    private

    # Get children
    # @param [Integer] height Tree height.
    # @param [String] key
    # @return [Array(MSSMT::BranchNode|MSSMT::LeafNode)]
    # @raise [MSSMT::Error]
    def get_children(height, key)
      node = get_node(height, key)
      if node.is_a?(MSSMT::BranchNode)
        return [
          get_node(height + 1, node.left.node_hash),
          get_node(height + 1, node.right.node_hash)
        ]
      end
      raise MSSMT::Error, "unexpected node type with key: #{key}"
    end

    def get_node(height, key)
      return empty_tree[height] if empty_tree[height].node_hash == key
      store.branches[key] || store.leaves[key]
    end

    # Walk down tree from root and return leaf node.
    # @param [String] key
    # @return [MSSMT::LeafNode] Leaf node corresponding to key.
    def walk_down(key)
      current = root_node
      MSSMT::Tree::MAX_LEVEL.times do |i|
        left, right = get_children(i, current.node_hash)
        next_node, sibling =
          bit_index(i, key).zero? ? [left, right] : [right, left]
        yield(i, next_node, sibling, current)
        current = next_node
      end
      current
    end

    # Walk up from the +start+ leaf node up to the root with the help of +siblings+.
    # @param [String] key
    # @param [MSSMT::LeafNode] start Start leaf node.
    # @param [Array] siblings
    # @return [MSSMT::BranchNode] The root branch node computed.
    def walk_up(key, start, siblings)
      current = start
      MAX_LEVEL.times do |index|
        i = LAST_BIT_INDEX - index
        sibling = siblings[LAST_BIT_INDEX - i]
        left, right =
          bit_index(i, key).zero? ? [current, sibling] : [sibling, current]
        parent = BranchNode.new(left, right)
        yield(i, current, sibling, parent)
        current = parent
      end
      current
    end

    def bit_index(idx, key)
      value = [key].pack("H*")[idx / 8].ord
      (value >> (idx % 8)) & 1
    end

    # Generate empty tree.
    # @return [Array]
    def build_empty_tree
      tree = Array.new(MSSMT::Tree::MAX_LEVEL + 1)
      tree[MSSMT::Tree::MAX_LEVEL] = MSSMT::LeafNode.empty_leaf
      MSSMT::Tree::MAX_LEVEL.times do |i|
        branch =
          MSSMT::BranchNode.new(
            tree[MSSMT::Tree::MAX_LEVEL - i],
            tree[MSSMT::Tree::MAX_LEVEL - i]
          )
        tree[MSSMT::Tree::MAX_LEVEL - (i + 1)] = branch
      end
      tree
    end
  end
end

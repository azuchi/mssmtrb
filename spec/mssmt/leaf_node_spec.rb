# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MSSMT::LeafNode do
  describe '#node_hash' do
    it 'return hash value' do
      expect(described_class.empty_leaf.node_hash.unpack1('H*')).to eq(
        'af5570f5a1810b7af78caf4bc70a660f0df51e42baf91d4de5b2328de0e83dfc'
      )
    end
  end
end

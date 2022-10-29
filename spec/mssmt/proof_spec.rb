# frozen_string_literal: true

require "spec_helper"

RSpec.describe MSSMT::Proof do
  describe "encode and decode" do
    it do
      leaves = load_leaves("encode.csv")
      tree = MSSMT::Tree.new
      leaves.each { |k, v| tree.insert(k, v) }

      proof =
        tree.merkle_proof(
          "89bd90da8b7d26690b07ce1a851fbdcd63582f4e9e14d6c85c6685ea7ecce1cc"
        )
      compressed = proof.compress
      expect(compressed.encode.unpack1("H*")).to eq(
        File.read(fixture_path("compressed.hex"))
      )

      leaves.each do |k, _|
        proof = tree.merkle_proof(k)
        compressed = proof.compress
        encoded = compressed.encode
        decoded = MSSMT::CompressedProof.decode(encoded)
        expect(compressed).to eq(decoded)
        expect(decoded.decompress == proof).to be true
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe MSSMT::Proof do
  describe "encode and decode" do
    it do
      leaves =
        load_leaves(
          "ac5d459d070650fa031b61c8d1fa785352575a4234537b63953a21c4aba56bac.csv"
        )
      tree = MSSMT::Tree.new
      leaves.each { |k, v| tree.insert(k, v) }

      proof =
        tree.merkle_proof(
          "a2b60af38e5e65bcbc53854a366afa318b0cddaba543650184d141269d7b51dc"
        )
      compressed = proof.compress
      expect(compressed.encode.unpack1("H*")).to eq(
        File.read(fixture_path("compressed.hex"))
      )

      leaves.each_key do |k|
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

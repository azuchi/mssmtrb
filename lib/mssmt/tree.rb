# frozen_string_literal: true

module MSSMT
  # MS-SMT tree
  module Tree
    autoload :Simple, "mssmt/tree/simple"
    # Depth of the MS-SMT(using SHA256)
    MAX_LEVEL = 256
    # Index of the last bit for MS-SMT keys
    LAST_BIT_INDEX = MAX_LEVEL - 1
  end
end

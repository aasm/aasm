require 'rails/generators/named_base'

module AASM
  module Generators
    class AASMGenerator < Rails::Generators::NamedBase
      namespace "aasm"
      argument :column_name, type: :string, default: 'aasm_state'

      desc "Generates a model with the given NAME (if one does not exist) with aasm " <<
      "block and migration to add aasm_state column."

      hook_for :orm

    end
  end
end

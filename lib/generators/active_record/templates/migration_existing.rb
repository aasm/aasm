class AddAasmTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name %>, :<%= column_name %>, :string
  end

  def self.down
    remove_column :<%= table_name %>, :<%= column_name %>
  end
end

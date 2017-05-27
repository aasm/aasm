class Add<%= column_name.camelize %>To<%= table_name.camelize %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    add_column :<%= table_name %>, :<%= column_name %>, :string
  end
end

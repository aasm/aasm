class AASMCreate<%= table_name.camelize %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table(:<%= table_name %>) do |t|
      t.string :<%= column_name %>
      t.timestamps null: false 
    end
  end
end

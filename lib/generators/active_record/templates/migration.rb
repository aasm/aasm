class AASMCreate<%= table_name.camelize %> < ActiveRecord::Migration[<%=  ActiveRecord::VERSION::STRING.to_f %>]
  def change
    create_table(:<%= table_name %>) do |t|
      t.string :<%= column_name %>
      t.timestamps null: false 
    end
  end
end

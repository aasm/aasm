class Add<%= column_name.camelize %>To<%= table_name.camelize %> < ActiveRecord::Migration[<%=  ActiveRecord::VERSION::STRING.to_f %>]
  def change
    add_column :<%= table_name %>, :<%= column_name %>, :string
  end
end

class CreateAasmStateChangeLogs < ActiveRecord::Migration
  def change
    create_table :aasm_state_change_logs do |t|
      t.integer :model_id
      t.string :model_type
      t.string :from_state
      t.string :to_state
      t.string :transition_event
      # You can add you own custom columns and make use of aasm.custom_column_values

      t.timestamps
    end
    
    add_index :aasm_state_change_logs, [:model_id, :model_type]
    # Here are some other suggested indeces
    # add_index :aasm_state_change_logs, [:created_at, :to_state]
    # add_index :aasm_state_change_logs, [:to_state, :from_state]
  end
end

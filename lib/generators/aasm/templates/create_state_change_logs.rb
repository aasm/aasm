class CreateStateChangeLogs < ActiveRecord::Migration
  def change
    create_table :state_change_logs do |t|
      t.integer :model_id
      t.string :model_type
      t.string :from_state
      t.string :to_state
      t.string :transition_event
      t.integer :user_id
      t.integer :reason_id
      t.string :comment

      t.timestamps
    end
    
    add_index :state_change_logs, [:model_id, :model_type]
  end
end

ActiveRecord::Migration.suppress_messages do
  %w{gates multiple_gates readers writers transients simples no_scopes multiple_no_scopes no_direct_assignments multiple_no_direct_assignments thieves multiple_thieves localizer_test_models persisted_states provided_and_persisted_states with_enums with_true_enums with_false_enums false_states multiple_with_enums multiple_with_true_enums multiple_with_false_enums multiple_false_states}.each do |table_name|
    ActiveRecord::Migration.create_table table_name, :force => true do |t|
      t.string "aasm_state"
    end
  end

  ActiveRecord::Migration.create_table "simple_new_dsls", :force => true do |t|
    t.string "status"
  end
  ActiveRecord::Migration.create_table "multiple_simple_new_dsls", :force => true do |t|
    t.string "status"
  end

  ActiveRecord::Migration.create_table "complex_active_record_examples", :force => true do |t|
    t.string "left"
    t.string "right"
  end

  ActiveRecord::Migration.create_table "validators", :force => true do |t|
    t.string "name"
    t.string "status"
  end
  ActiveRecord::Migration.create_table "multiple_validators", :force => true do |t|
    t.string "name"
    t.string "status"
  end

  ActiveRecord::Migration.create_table "transactors", :force => true do |t|
    t.string "name"
    t.string "status"
    t.integer "worker_id"
  end
  ActiveRecord::Migration.create_table "multiple_transactors", :force => true do |t|
    t.string "name"
    t.string "status"
    t.integer "worker_id"
  end

  ActiveRecord::Migration.create_table "workers", :force => true do |t|
    t.string "name"
    t.string "status"
  end

  ActiveRecord::Migration.create_table "invalid_persistors", :force => true do |t|
    t.string "name"
    t.string "status"
  end
  ActiveRecord::Migration.create_table "multiple_invalid_persistors", :force => true do |t|
    t.string "name"
    t.string "status"
  end

  ActiveRecord::Migration.create_table "fathers", :force => true do |t|
    t.string "aasm_state"
    t.string "type"
  end

  ActiveRecord::Migration.create_table "basic_active_record_two_state_machines_examples", :force => true do |t|
    t.string "search"
    t.string "sync"
  end
end

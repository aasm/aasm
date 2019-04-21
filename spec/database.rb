ActiveRecord::Migration.suppress_messages do
  %w{gates multiple_gates readers writers transients simples no_scopes multiple_no_scopes no_direct_assignments multiple_no_direct_assignments thieves multiple_thieves localizer_test_models persisted_states provided_and_persisted_states with_enums with_enum_without_columns multiple_with_enum_without_columns with_true_enums with_false_enums false_states multiple_with_enums multiple_with_true_enums multiple_with_false_enums multiple_false_states readme_jobs}.each do |table_name|
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
  ActiveRecord::Migration.create_table "implemented_abstract_class_dsls", :force => true do |t|
    t.string "status"
  end
  ActiveRecord::Migration.create_table "users", :force => true do |t|
    t.string "status"
  end

  ActiveRecord::Migration.create_table "complex_active_record_examples", :force => true do |t|
    t.string "left"
    t.string "right"
  end

  ActiveRecord::Migration.create_table "works", :force => true do |t|
    t.string "status"
  end

  %w(validators multiple_validators workers invalid_persistors multiple_invalid_persistors silent_persistors multiple_silent_persistors).each do |table_name|
    ActiveRecord::Migration.create_table table_name, :force => true do |t|
      t.string "name"
      t.string "status"
    end
  end

  %w(transactors no_lock_transactors lock_transactors lock_no_wait_transactors no_transactors multiple_transactors).each do |table_name|
    ActiveRecord::Migration.create_table table_name, :force => true do |t|
      t.string "name"
      t.string "status"
      t.integer "worker_id"
    end
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

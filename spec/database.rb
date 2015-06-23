ActiveRecord::Migration.suppress_messages do
  %w{gates readers writers transients simples  no_scopes no_direct_assignments thieves localizer_test_models persisted_states provided_and_persisted_states with_enums with_true_enums with_false_enums false_states}.each do |table_name|
    ActiveRecord::Migration.create_table table_name, :force => true do |t|
      t.string "aasm_state"
    end
  end

  ActiveRecord::Migration.create_table "cards", :force => true do |t|
    t.string "status"
  end

  ActiveRecord::Migration.create_table "simple_new_dsls", :force => true do |t|
    t.string "status"
  end

  ActiveRecord::Migration.create_table "validators", :force => true do |t|
    t.string "name"
    t.string "status"
  end

  ActiveRecord::Migration.create_table "transactors", :force => true do |t|
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

  ActiveRecord::Migration.create_table "fathers", :force => true do |t|
    t.string "aasm_state"
    t.string "type"
  end
end

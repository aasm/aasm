ActiveRecord::Migration.suppress_messages do
  %w{gates readers writers transients simples simple_new_dsls no_scopes thieves localizer_test_models persisted_states provided_and_persisted_states}.each do |table_name|
    ActiveRecord::Migration.create_table table_name, :force => true do |t|
      t.string "aasm_state"
    end
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

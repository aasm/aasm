require 'spec_helper'
require 'generator_spec'
require 'generators/active_record/aasm_generator'

describe ActiveRecord::Generators::AASMGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)

  before(:all) do
    prepare_destination
  end

  it "creates model with aasm block for default column_name" do
    run_generator %w(user)
    assert_file "app/models/user.rb", /include AASM\n\n  aasm do\n  end\n/
  end

  it "creates model with aasm block for custom column_name" do
    run_generator %w(user state)
    assert_file "app/models/user.rb", /aasm :column => 'state' do\n  end\n/
  end

  it "creates model with aasm block for namespaced model" do
    run_generator %w(Admin::User state)
    assert_file "app/models/admin/user.rb", /aasm :column => 'state' do\n  end\n/
  end

  it "creates migration for model with aasm_column" do
    run_generator %w(post)
    assert_migration "db/migrate/aasm_create_posts.rb", /create_table(:posts) do |t|\n  t.string :aasm_state\n/
  end

  it "add aasm_column in existing model" do
    run_generator %w(job)
    assert_file "app/models/job.rb"
    run_generator %w(job)
    assert_migration "db/migrate/add_aasm_state_to_jobs.rb"
  end

end

require 'spec_helper'

if defined?(Mongoid::Document)
  require 'generator_spec'
  require 'generators/mongoid/aasm_generator'

  describe Mongoid::Generators::AASMGenerator, type: :generator do
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

  end

end

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'aasm')

begin
  require 'rubygems'
  require 'active_record'

  # A dummy class for mocking the activerecord connection class
  class Connection
  end

  class FooBar < ActiveRecord::Base
    include AASM

    # Fake this column for testing purposes
    attr_accessor :aasm_state

    aasm_state :open
    aasm_state :closed

    aasm_event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end

  class Fi < ActiveRecord::Base
    def aasm_read_state
      "fi"
    end
    include AASM
  end

  class Fo < ActiveRecord::Base
    def aasm_write_state(state)
      "fo"
    end
    include AASM
  end

  class Fum < ActiveRecord::Base
    def aasm_write_state_without_persistence(state)
      "fum"
    end
    include AASM
  end

  class June < ActiveRecord::Base
    include AASM
    aasm_column :status
  end

  class Beaver < June
  end

  describe "aasm model", :shared => true do
    it "should include AASM::Persistence::ActiveRecordPersistence" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence)
    end
    it "should include AASM::Persistence::ActiveRecordPersistence::InstanceMethods" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::InstanceMethods)
    end
  end

  describe FooBar, "class methods" do
    before(:each) do
      @klass = FooBar
    end
    it_should_behave_like "aasm model"
    it "should include AASM::Persistence::ActiveRecordPersistence::ReadState" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::ReadState)
    end
    it "should include AASM::Persistence::ActiveRecordPersistence::WriteState" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::WriteState)
    end
    it "should include AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence)
    end
  end

  describe Fi, "class methods" do
    before(:each) do
      @klass = Fi
    end
    it_should_behave_like "aasm model"
    it "should not include AASM::Persistence::ActiveRecordPersistence::ReadState" do
      @klass.included_modules.should_not be_include(AASM::Persistence::ActiveRecordPersistence::ReadState)
    end
    it "should include AASM::Persistence::ActiveRecordPersistence::WriteState" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::WriteState)
    end
    it "should include AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence)
    end
  end

  describe Fo, "class methods" do
    before(:each) do
      @klass = Fo
    end
    it_should_behave_like "aasm model"
    it "should include AASM::Persistence::ActiveRecordPersistence::ReadState" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::ReadState)
    end
    it "should not include AASM::Persistence::ActiveRecordPersistence::WriteState" do
      @klass.included_modules.should_not be_include(AASM::Persistence::ActiveRecordPersistence::WriteState)
    end
    it "should include AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence)
    end
  end

  describe Fum, "class methods" do
    before(:each) do
      @klass = Fum
    end
    it_should_behave_like "aasm model"
    it "should include AASM::Persistence::ActiveRecordPersistence::ReadState" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::ReadState)
    end
    it "should include AASM::Persistence::ActiveRecordPersistence::WriteState" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::WriteState)
    end
    it "should not include AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence" do
      @klass.included_modules.should_not be_include(AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence)
    end
  end

  describe FooBar, "instance methods" do
    before(:each) do
      connection = mock(Connection, :columns => [])
      FooBar.stub!(:connection).and_return(connection)
    end

    it "should respond to aasm read state when not previously defined" do
      FooBar.new.should respond_to(:aasm_read_state)
    end

    it "should respond to aasm write state when not previously defined" do
      FooBar.new.should respond_to(:aasm_write_state)
    end

    it "should respond to aasm write state without persistence when not previously defined" do
      FooBar.new.should respond_to(:aasm_write_state_without_persistence)
    end

    it "should return the initial state when new and the aasm field is nil" do
      FooBar.new.aasm_current_state.should == :open
    end

    it "should return the aasm column when new and the aasm field is not nil" do
      foo = FooBar.new
      foo.aasm_state = "closed"
      foo.aasm_current_state.should == :closed
    end

    it "should return the aasm column when not new and the aasm_column is not nil" do
      foo = FooBar.new
      foo.stub!(:new_record?).and_return(false)
      foo.aasm_state = "state"
      foo.aasm_current_state.should == :state
    end

    it "should allow a nil state" do
      foo = FooBar.new
      foo.stub!(:new_record?).and_return(false)
      foo.aasm_state = nil
      foo.aasm_current_state.should be_nil
    end

    it "should have aasm_ensure_initial_state" do
      foo = FooBar.new
      foo.send :aasm_ensure_initial_state
    end

    it "should call aasm_ensure_initial_state on validation before create" do
      foo = FooBar.new
      foo.should_receive(:aasm_ensure_initial_state).and_return(true)
      foo.valid?
    end

    it "should call aasm_ensure_initial_state on validation before create" do
      foo = FooBar.new
      foo.stub!(:new_record?).and_return(false)
      foo.should_not_receive(:aasm_ensure_initial_state)
      foo.valid?
    end

  end

  describe 'Beavers' do
    it "should have the same states as it's parent" do
      Beaver.aasm_states.should == June.aasm_states
    end

    it "should have the same events as it's parent" do
      Beaver.aasm_events.should == June.aasm_events
    end

    it "should have the same column as it's parent" do
      Beaver.aasm_column.should == :status
    end
  end

  describe AASM::Persistence::ActiveRecordPersistence::NamedScopeMethods do
    class NamedScopeExample < ActiveRecord::Base
      include AASM
    end

    context "Does not already respond_to? the scope name" do
      it "should add a named_scope" do
        NamedScopeExample.should_receive(:named_scope)
        NamedScopeExample.aasm_state :unknown_scope
      end
    end

    context "Already respond_to? the scope name" do
      it "should not add a named_scope" do
        NamedScopeExample.should_not_receive(:named_scope)
        NamedScopeExample.aasm_state :new
      end
    end
  end

  # TODO: figure out how to test ActiveRecord reload! without a database

rescue LoadError => e
  if e.message == "no such file to load -- active_record"
    puts "You must install active record to run this spec.  Install with sudo gem install activerecord"
  else
    raise
  end
end

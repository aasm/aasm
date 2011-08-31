begin
  require 'rubygems'
  require 'active_record'
  require 'logger'

  load_schema

  ActiveRecord::Base.logger = Logger.new(STDERR)

  class Gate < ActiveRecord::Base
    include AASM

    # Fake this column for testing purposes
    attr_accessor :aasm_state

    aasm_state :opened
    aasm_state :closed

    aasm_event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end

  class Reader < ActiveRecord::Base
    def aasm_read_state
      "fi"
    end
    include AASM
  end

  class Writer < ActiveRecord::Base
    def aasm_write_state(state)
      "fo"
    end
    include AASM
  end

  class Transient < ActiveRecord::Base
    def aasm_write_state_without_persistence(state)
      "fum"
    end
    include AASM
  end

  class Simple < ActiveRecord::Base
    include AASM
    aasm_column :status
  end

  class Derivate < Simple
  end

  class Thief < ActiveRecord::Base
    set_table_name "thieves"
    include AASM
    aasm_initial_state  Proc.new { |thief| thief.skilled ? :rich : :jailed }
    aasm_state          :rich
    aasm_state          :jailed
    attr_accessor :skilled, :aasm_state
  end

  shared_examples_for "aasm model" do
    it "should include AASM::Persistence::ActiveRecordPersistence" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence)
    end
    it "should include AASM::Persistence::ActiveRecordPersistence::InstanceMethods" do
      @klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::InstanceMethods)
    end
  end

  describe Gate, "class methods" do
    before(:each) do
      @klass = Gate
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

  describe Reader, "class methods" do
    before(:each) do
      @klass = Reader
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

  describe Writer, "class methods" do
    before(:each) do
      @klass = Writer
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

  describe Transient, "class methods" do
    before(:each) do
      @klass = Transient
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

  describe Gate, "instance methods" do

    it "should respond to aasm read state when not previously defined" do
      Gate.new.should respond_to(:aasm_read_state)
    end

    it "should respond to aasm write state when not previously defined" do
      Gate.new.should respond_to(:aasm_write_state)
    end

    it "should respond to aasm write state without persistence when not previously defined" do
      Gate.new.should respond_to(:aasm_write_state_without_persistence)
    end

    it "should return the initial state when new and the aasm field is nil" do
      Gate.new.aasm_current_state.should == :opened
    end

    it "should return the aasm column when new and the aasm field is not nil" do
      foo = Gate.new
      foo.aasm_state = "closed"
      foo.aasm_current_state.should == :closed
    end

    it "should return the aasm column when not new and the aasm_column is not nil" do
      foo = Gate.new
      foo.stub!(:new_record?).and_return(false)
      foo.aasm_state = "state"
      foo.aasm_current_state.should == :state
    end

    it "should allow a nil state" do
      foo = Gate.new
      foo.stub!(:new_record?).and_return(false)
      foo.aasm_state = nil
      foo.aasm_current_state.should be_nil
    end

    it "should have aasm_ensure_initial_state" do
      foo = Gate.new
      foo.send :aasm_ensure_initial_state
    end

    it "should call aasm_ensure_initial_state on validation before create" do
      foo = Gate.new
      foo.should_receive(:aasm_ensure_initial_state).and_return(true)
      foo.valid?
    end

    it "should call aasm_ensure_initial_state on validation before create" do
      foo = Gate.new
      foo.stub!(:new_record?).and_return(false)
      foo.should_not_receive(:aasm_ensure_initial_state)
      foo.valid?
    end

  end

  describe 'Derivates' do
    it "should have the same states as it's parent" do
      Derivate.aasm_states.should == Simple.aasm_states
    end

    it "should have the same events as it's parent" do
      Derivate.aasm_events.should == Simple.aasm_events
    end

    it "should have the same column as it's parent" do
      Derivate.aasm_column.should == :status
    end
  end

  describe AASM::Persistence::ActiveRecordPersistence::NamedScopeMethods do

    context "Does not already respond_to? the scope name" do
      it "should add a scope" do
        Simple.should_not respond_to(:unknown_scope)
        Simple.aasm_state :unknown_scope
        Simple.should respond_to(:unknown_scope)
        Simple.unknown_scope.class.should == ActiveRecord::Relation
      end
    end

    context "Already respond_to? the scope name" do
      it "should not add a scope" do
        Simple.aasm_state :new
        Simple.should respond_to(:new)
        Simple.new.class.should == Simple
      end
    end
  end

  describe 'Thieves' do

    it 'should be rich if they\'re skilled' do
      Thief.new(:skilled => true).aasm_current_state.should == :rich
    end

    it 'should be jailed if they\'re unskilled' do
      Thief.new(:skilled => false).aasm_current_state.should == :jailed
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

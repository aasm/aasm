require 'rubygems'
require 'active_record'
require 'logger'

load_schema

ActiveRecord::Base.logger = Logger.new(STDERR)

class Gate < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  attr_accessor :aasm_state

  aasm do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
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
  aasm_state :unknown_scope
  aasm_state :new
end

class SimpleNewDsl < ActiveRecord::Base
  include AASM
  aasm :column => :status
  aasm do
    state :unknown_scope
    state :new
  end
end

class Derivate < Simple
end

class DerivateNewDsl < SimpleNewDsl
end

class Thief < ActiveRecord::Base
  if ActiveRecord::VERSION::MAJOR >= 3
    self.table_name = 'thieves'
  else
    set_table_name "thieves"
  end
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

  before do
    @gate = Gate.new
  end

  it "should respond to aasm read state when not previously defined" do
    @gate.should respond_to(:aasm_read_state)
  end

  it "should respond to aasm write state when not previously defined" do
    @gate.should respond_to(:aasm_write_state)
  end

  it "should respond to aasm write state without persistence when not previously defined" do
    @gate.should respond_to(:aasm_write_state_without_persistence)
  end

  it "should return the initial state when new and the aasm field is nil" do
    @gate.aasm_current_state.should == :opened
  end

  it "should return the aasm column when new and the aasm field is not nil" do
    @gate.aasm_state = "closed"
    @gate.aasm_current_state.should == :closed
  end

  it "should return the aasm column when not new and the aasm_column is not nil" do
    @gate.stub!(:new_record?).and_return(false)
    @gate.aasm_state = "state"
    @gate.aasm_current_state.should == :state
  end

  it "should allow a nil state" do
    @gate.stub!(:new_record?).and_return(false)
    @gate.aasm_state = nil
    @gate.aasm_current_state.should be_nil
  end

  it "should have aasm_ensure_initial_state" do
    @gate.send :aasm_ensure_initial_state
  end

  it "should call aasm_ensure_initial_state on validation before create" do
    @gate.should_receive(:aasm_ensure_initial_state).and_return(true)
    @gate.valid?
  end

  it "should call aasm_ensure_initial_state on validation before create" do
    @gate.stub!(:new_record?).and_return(false)
    @gate.should_not_receive(:aasm_ensure_initial_state)
    @gate.valid?
  end

end

describe 'Derivates' do
  it "should have the same states as its parent" do
    Derivate.aasm_states.should == Simple.aasm_states
  end

  it "should have the same events as its parent" do
    Derivate.aasm_events.should == Simple.aasm_events
  end

  it "should have the same column as its parent" do
    Derivate.aasm_column.should == :status
  end

  it "should have the same column as its parent even for the new dsl" do
    SimpleNewDsl.aasm_column.should == :status
    DerivateNewDsl.aasm_column.should == :status
  end
end

describe "AASM::Persistence::ActiveRecordPersistence::NamedScopeMethods" do

  context "Old DSL Does not already respond_to? the scope name" do
    it "should add a scope" do
      Simple.should respond_to(:unknown_scope)
      Simple.unknown_scope.class.should == ActiveRecord::Relation
    end
  end

  context "Old DSL Already respond_to? the scope name" do
    it "should not add a scope" do
      Simple.should respond_to(:new)
      Simple.new.class.should == Simple
    end
  end

  context "New DSL Does not already respond_to? the scope name" do
    it "should add a scope" do
      SimpleNewDsl.should respond_to(:unknown_scope)
      SimpleNewDsl.unknown_scope.class.should == ActiveRecord::Relation
    end
  end

  context "New DSL Already respond_to? the scope name" do
    it "should not add a scope" do
      SimpleNewDsl.should respond_to(:new)
      SimpleNewDsl.new.class.should == SimpleNewDsl
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

describe 'transitions with persistence' do

  it 'should not store states for invalid models' do
    validator = Validator.create(:name => 'name')
    validator.should be_valid
    validator.should be_sleeping

    validator.name = nil
    validator.should_not be_valid
    validator.run!.should be_false
    validator.should be_sleeping

    validator.reload
    validator.should_not be_running
    validator.should be_sleeping

    validator.name = 'another name'
    validator.should be_valid
    validator.run!.should be_true
    validator.should be_running

    validator.reload
    validator.should be_running
    validator.should_not be_sleeping
  end

  it 'should store states for invalid models if configured' do
    persistor = InvalidPersistor.create(:name => 'name')
    persistor.should be_valid
    persistor.should be_sleeping

    persistor.name = nil
    persistor.should_not be_valid
    persistor.run!.should be_true
    persistor.should be_running

    persistor = InvalidPersistor.find(persistor.id)
    persistor.valid?
    persistor.should be_valid
    persistor.should be_running
    persistor.should_not be_sleeping

    persistor.reload
    persistor.should be_running
    persistor.should_not be_sleeping
  end

end

require 'active_record'
require 'logger'
require 'spec_helper'

load_schema

# if you want to see the statements while running the spec enable the following line
# ActiveRecord::Base.logger = Logger.new(STDERR)

shared_examples_for "aasm model" do
  it "should include persistence mixins" do
    klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence)
    klass.included_modules.should be_include(AASM::Persistence::ActiveRecordPersistence::InstanceMethods)
  end
end

describe "instance methods" do
  let(:gate) {Gate.new}

  it "should respond to aasm persistence methods" do
    gate.should respond_to(:aasm_read_state)
    gate.should respond_to(:aasm_write_state)
    gate.should respond_to(:aasm_write_state_without_persistence)
  end

  it "should return the initial state when new and the aasm field is nil" do
    gate.aasm_current_state.should == :opened
  end

  it "should return the aasm column when new and the aasm field is not nil" do
    gate.aasm_state = "closed"
    gate.aasm_current_state.should == :closed
  end

  it "should return the aasm column when not new and the aasm_column is not nil" do
    gate.stub(:new_record?).and_return(false)
    gate.aasm_state = "state"
    gate.aasm_current_state.should == :state
  end

  it "should allow a nil state" do
    gate.stub(:new_record?).and_return(false)
    gate.aasm_state = nil
    gate.aasm_current_state.should be_nil
  end

  it "should call aasm_ensure_initial_state on validation before create" do
    gate.should_receive(:aasm_ensure_initial_state).and_return(true)
    gate.valid?
  end

  it "should not call aasm_ensure_initial_state on validation before update" do
    gate.stub(:new_record?).and_return(false)
    gate.should_not_receive(:aasm_ensure_initial_state)
    gate.valid?
  end

end

describe 'subclasses' do
  it "should have the same states as its parent class" do
    Derivate.aasm_states.should == Simple.aasm_states
  end

  it "should have the same events as its parent class" do
    Derivate.aasm_events.should == Simple.aasm_events
  end

  it "should have the same column as its parent class" do
    Derivate.aasm_column.should == :status
  end

  it "should have the same column as its parent even for the new dsl" do
    SimpleNewDsl.aasm_column.should == :status
    DerivateNewDsl.aasm_column.should == :status
  end
end

describe "named scopes with the old DSL" do

  context "Does not already respond_to? the scope name" do
    it "should add a scope" do
      Simple.should respond_to(:unknown_scope)
      SimpleNewDsl.unknown_scope.is_a?(ActiveRecord::Relation).should be_true
    end
  end

  context "Already respond_to? the scope name" do
    it "should not add a scope" do
      Simple.should respond_to(:new)
      Simple.new.class.should == Simple
    end
  end

end

describe "named scopes with the new DSL" do

  context "Does not already respond_to? the scope name" do
    it "should add a scope" do
      SimpleNewDsl.should respond_to(:unknown_scope)
      SimpleNewDsl.unknown_scope.is_a?(ActiveRecord::Relation).should be_true
    end
  end

  context "Already respond_to? the scope name" do
    it "should not add a scope" do
      SimpleNewDsl.should respond_to(:new)
      SimpleNewDsl.new.class.should == SimpleNewDsl
    end
  end

  it "does not create scopes if requested" do
    NoScope.should_not respond_to(:ignored_scope)
  end

end

describe 'initial states' do

  it 'should support conditions' do
    Thief.new(:skilled => true).aasm_current_state.should == :rich
    Thief.new(:skilled => false).aasm_current_state.should == :jailed
  end
end

describe 'transitions with persistence' do

  it "should work for valid models" do
    valid_object = Validator.create(:name => 'name')
    valid_object.should be_sleeping
    valid_object.status = :running
    valid_object.should be_running
  end

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

  describe 'transactions' do
    let(:worker) { Worker.create!(:name => 'worker', :status => 'sleeping') }
    let(:transactor) { Transactor.create!(:name => 'transactor', :worker => worker) }

    it 'should rollback all changes' do
      transactor.should be_sleeping
      worker.status.should == 'sleeping'

      lambda {transactor.run!}.should raise_error(StandardError, 'failed on purpose')
      transactor.should be_running
      worker.reload.status.should == 'sleeping'
    end

    it "should rollback all changes in nested transaction" do
      transactor.should be_sleeping
      worker.status.should == 'sleeping'

      Worker.transaction do
        lambda { transactor.run! }.should raise_error(StandardError, 'failed on purpose')
      end

      transactor.should be_running
      worker.reload.status.should == 'sleeping'
    end

    describe "after_commit callback" do
      it "should fire :after_commit if transaction was successful" do
        validator = Validator.create(:name => 'name')
        validator.should be_sleeping
        validator.run!
        validator.should be_running
        validator.name.should_not == "name"
      end

      it "should not fire :after_commit if transaction failed" do
        validator = Validator.create(:name => 'name')
        lambda { validator.fail! }.should raise_error(StandardError, 'failed on purpose')
        validator.name.should == "name"
      end

    end
  end
end

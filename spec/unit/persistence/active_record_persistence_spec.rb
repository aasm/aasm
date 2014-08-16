require 'active_record'
require 'logger'
require 'spec_helper'

load_schema

# if you want to see the statements while running the spec enable the following line
# ActiveRecord::Base.logger = Logger.new(STDERR)

shared_examples_for "aasm model" do
  it "should include persistence mixins" do
    expect(klass.included_modules).to be_include(AASM::Persistence::ActiveRecordPersistence)
    expect(klass.included_modules).to be_include(AASM::Persistence::ActiveRecordPersistence::InstanceMethods)
  end
end

describe "instance methods" do
  let(:gate) {Gate.new}

  it "should respond to aasm persistence methods" do
    expect(gate).to respond_to(:aasm_read_state)
    expect(gate).to respond_to(:aasm_write_state)
    expect(gate).to respond_to(:aasm_write_state_without_persistence)
  end

  describe "aasm_column_looks_like_enum" do
    subject { lambda{ gate.send(:aasm_column_looks_like_enum) } }

    let(:column_name) { "value" }
    let(:columns_hash) { Hash[column_name, column] }

    before :each do
      gate.class.stub(:aasm_column).and_return(column_name.to_sym)
      gate.class.stub(:columns_hash).and_return(columns_hash)
    end

    context "when AASM column has integer type" do
      let(:column) { double(Object, type: :integer) }

      it "returns true" do
        expect(subject.call).to be_true
      end
    end

    context "when AASM column has string type" do
      let(:column) { double(Object, type: :string) }

      it "returns false" do
        expect(subject.call).to be_false
      end
    end
  end

  describe "aasm_guess_enum_method" do
    subject { lambda{ gate.send(:aasm_guess_enum_method) } }

    before :each do
      gate.class.stub(:aasm_column).and_return(:value)
    end

    it "pluralizes AASM column name" do
      expect(subject.call).to eq :values
    end
  end

  describe "aasm_enum" do
    subject { lambda{ gate.send(:aasm_enum) } }

    context "when AASM enum setting contains an explicit enum method name" do
      let(:enum) { :test }

      before :each do
        AASM::StateMachine[Gate].config.stub(:enum).and_return(enum)
      end

      it "returns whatever value was set in AASM config" do
        expect(subject.call).to eq enum
      end
    end

    context "when AASM enum setting is simply set to true" do
      before :each do
        AASM::StateMachine[Gate].config.stub(:enum).and_return(true)
        Gate.stub(:aasm_column).and_return(:value)
        gate.stub(:aasm_guess_enum_method).and_return(:values)
      end

      it "infers enum method name from pluralized column name" do
        expect(subject.call).to eq :values
        expect(gate).to have_received :aasm_guess_enum_method
      end
    end

    context "when AASM enum setting is explicitly disabled" do
      before :each do
        AASM::StateMachine[Gate].config.stub(:enum).and_return(false)
      end

      it "returns nil" do
        expect(subject.call).to be_nil
      end
    end

    context "when AASM enum setting is not enabled" do
      before :each do
        AASM::StateMachine[Gate].config.stub(:enum).and_return(nil)
        Gate.stub(:aasm_column).and_return(:value)
      end

      context "when AASM column looks like enum" do
        before :each do
          gate.stub(:aasm_column_looks_like_enum).and_return(true)
          gate.stub(:aasm_guess_enum_method).and_return(:values)
        end

        it "infers enum method name from pluralized column name" do
          expect(subject.call).to eq :values
          expect(gate).to have_received :aasm_guess_enum_method
        end
      end

      context "when AASM column doesn't look like enum'" do
        before :each do
          gate.stub(:aasm_column_looks_like_enum)
            .and_return(false)
        end

        it "returns nil, as we're not using enum" do
          expect(subject.call).to be_nil
        end
      end
    end
  end

  context "when AASM is configured to use enum" do
    let(:state_sym) { :running }
    let(:state_code) { 2 }
    let(:enum_name) { :states }
    let(:enum) { Hash[state_sym, state_code] }

    before :each do
      gate
        .stub(:aasm_enum)
        .and_return(enum_name)
      gate.stub(:aasm_write_attribute)
      gate.stub(:write_attribute)

      gate
        .class
        .stub(enum_name)
        .and_return(enum)
    end

    describe "aasm_write_state" do
      context "when AASM is configured to skip validations on save" do
        before :each do
          gate
            .stub(:aasm_skipping_validations)
            .and_return(true)
        end

        it "passes state code instead of state symbol to update_all" do
          # stub_chain does not allow us to give expectations on call
          # parameters in the middle of the chain, so we need to use
          # intermediate object instead.
          obj = double(Object, update_all: 1)
          gate
            .class
            .stub(:where)
            .and_return(obj)

          gate.aasm_write_state state_sym

          expect(obj).to have_received(:update_all)
            .with(Hash[gate.class.aasm_column, state_code])
        end
      end

      context "when AASM is not skipping validations" do
        it "delegates state update to the helper method" do
          # Let's pretend that validation is passed
          gate.stub(:save).and_return(true)

          gate.aasm_write_state state_sym

          expect(gate).to have_received(:aasm_write_attribute).with(state_sym)
          expect(gate).to_not have_received :write_attribute
        end
      end
    end

    describe "aasm_write_state_without_persistence" do
      it "delegates state update to the helper method" do
        gate.aasm_write_state_without_persistence state_sym

        expect(gate).to have_received(:aasm_write_attribute).with(state_sym)
        expect(gate).to_not have_received :write_attribute
      end
    end

    describe "aasm_raw_attribute_value" do
      it "converts state symbol to state code" do
        expect(gate.send(:aasm_raw_attribute_value, state_sym))
          .to eq state_code
      end
    end
  end

  context "when AASM is configured to use string field" do
    let(:state_sym) { :running }

    before :each do
      gate
        .stub(:aasm_enum)
        .and_return(nil)
    end

    describe "aasm_raw_attribute_value" do
      it "converts state symbol to string" do
        expect(gate.send(:aasm_raw_attribute_value, state_sym))
          .to eq state_sym.to_s
      end
    end
  end

  describe "aasm_write_attribute helper method" do
    let(:sym) { :sym }
    let(:value) { 42 }

    before :each do
      gate.stub(:write_attribute)
      gate.stub(:aasm_raw_attribute_value)
        .and_return(value)

      gate.send(:aasm_write_attribute, sym)
    end

    it "generates attribute value using a helper method" do
      expect(gate).to have_received(:aasm_raw_attribute_value).with(sym)
    end

    it "writes attribute to the model" do
      expect(gate).to have_received(:write_attribute).with(:aasm_state, value)
    end
  end

  it "should return the initial state when new and the aasm field is nil" do
    expect(gate.aasm.current_state).to eq(:opened)
  end

  it "should return the aasm column when new and the aasm field is not nil" do
    gate.aasm_state = "closed"
    expect(gate.aasm.current_state).to eq(:closed)
  end

  it "should return the aasm column when not new and the aasm_column is not nil" do
    allow(gate).to receive(:new_record?).and_return(false)
    gate.aasm_state = "state"
    expect(gate.aasm.current_state).to eq(:state)
  end

  it "should allow a nil state" do
    allow(gate).to receive(:new_record?).and_return(false)
    gate.aasm_state = nil
    expect(gate.aasm.current_state).to be_nil
  end

  it "should call aasm_ensure_initial_state on validation before create" do
    expect(gate).to receive(:aasm_ensure_initial_state).and_return(true)
    gate.valid?
  end

  it "should call aasm_ensure_initial_state before create, even if skipping validations" do
    expect(gate).to receive(:aasm_ensure_initial_state).and_return(true)
    gate.save(:validate => false)
  end

  it "should not call aasm_ensure_initial_state on validation before update" do
    allow(gate).to receive(:new_record?).and_return(false)
    expect(gate).not_to receive(:aasm_ensure_initial_state)
    gate.valid?
  end

end

describe 'subclasses' do
  it "should have the same states as its parent class" do
    expect(DerivateNewDsl.aasm.states).to eq(SimpleNewDsl.aasm.states)
  end

  it "should have the same events as its parent class" do
    expect(DerivateNewDsl.aasm.events).to eq(SimpleNewDsl.aasm.events)
  end

  it "should have the same column as its parent even for the new dsl" do
    expect(SimpleNewDsl.aasm_column).to eq(:status)
    expect(DerivateNewDsl.aasm_column).to eq(:status)
  end
end

describe "named scopes with the new DSL" do
  context "Does not already respond_to? the scope name" do
    it "should add a scope" do
      expect(SimpleNewDsl).to respond_to(:unknown_scope)
      expect(SimpleNewDsl.unknown_scope.is_a?(ActiveRecord::Relation)).to be_true
    end
  end

  context "Already respond_to? the scope name" do
    it "should not add a scope" do
      expect(SimpleNewDsl).to respond_to(:new)
      expect(SimpleNewDsl.new.class).to eq(SimpleNewDsl)
    end
  end

  it "does not create scopes if requested" do
    expect(NoScope).not_to respond_to(:ignored_scope)
  end

end

describe 'initial states' do

  it 'should support conditions' do
    expect(Thief.new(:skilled => true).aasm.current_state).to eq(:rich)
    expect(Thief.new(:skilled => false).aasm.current_state).to eq(:jailed)
  end
end

describe 'transitions with persistence' do

  it "should work for valid models" do
    valid_object = Validator.create(:name => 'name')
    expect(valid_object).to be_sleeping
    valid_object.status = :running
    expect(valid_object).to be_running
  end

  it 'should not store states for invalid models' do
    validator = Validator.create(:name => 'name')
    expect(validator).to be_valid
    expect(validator).to be_sleeping

    validator.name = nil
    expect(validator).not_to be_valid
    expect(validator.run!).to be_false
    expect(validator).to be_sleeping

    validator.reload
    expect(validator).not_to be_running
    expect(validator).to be_sleeping

    validator.name = 'another name'
    expect(validator).to be_valid
    expect(validator.run!).to be_true
    expect(validator).to be_running

    validator.reload
    expect(validator).to be_running
    expect(validator).not_to be_sleeping
  end

  it 'should store states for invalid models if configured' do
    persistor = InvalidPersistor.create(:name => 'name')
    expect(persistor).to be_valid
    expect(persistor).to be_sleeping

    persistor.name = nil
    expect(persistor).not_to be_valid
    expect(persistor.run!).to be_true
    expect(persistor).to be_running

    persistor = InvalidPersistor.find(persistor.id)
    persistor.valid?
    expect(persistor).to be_valid
    expect(persistor).to be_running
    expect(persistor).not_to be_sleeping

    persistor.reload
    expect(persistor).to be_running
    expect(persistor).not_to be_sleeping
  end

  describe 'transactions' do
    let(:worker) { Worker.create!(:name => 'worker', :status => 'sleeping') }
    let(:transactor) { Transactor.create!(:name => 'transactor', :worker => worker) }

    it 'should rollback all changes' do
      expect(transactor).to be_sleeping
      expect(worker.status).to eq('sleeping')

      expect {transactor.run!}.to raise_error(StandardError, 'failed on purpose')
      expect(transactor).to be_running
      expect(worker.reload.status).to eq('sleeping')
    end

    context "nested transactions" do
      it "should rollback all changes in nested transaction" do
        expect(transactor).to be_sleeping
        expect(worker.status).to eq('sleeping')

        Worker.transaction do
          expect { transactor.run! }.to raise_error(StandardError, 'failed on purpose')
        end

        expect(transactor).to be_running
        expect(worker.reload.status).to eq('sleeping')
      end

      it "should only rollback changes in the main transaction not the nested one" do
        # change configuration to not require new transaction
        AASM::StateMachine[Transactor].config.requires_new_transaction = false

        expect(transactor).to be_sleeping
        expect(worker.status).to eq('sleeping')

        Worker.transaction do
          expect { transactor.run! }.to raise_error(StandardError, 'failed on purpose')
        end

        expect(transactor).to be_running
        expect(worker.reload.status).to eq('running')
      end
    end

    describe "after_commit callback" do
      it "should fire :after_commit if transaction was successful" do
        validator = Validator.create(:name => 'name')
        expect(validator).to be_sleeping
        validator.run!
        expect(validator).to be_running
        expect(validator.name).not_to eq("name")
      end

      it "should not fire :after_commit if transaction failed" do
        validator = Validator.create(:name => 'name')
        expect { validator.fail! }.to raise_error(StandardError, 'failed on purpose')
        expect(validator.name).to eq("name")
      end

      it "should not fire if not saving" do
        validator = Validator.create(:name => 'name')
        expect(validator).to be_sleeping
        validator.run
        expect(validator).to be_running
        expect(validator.name).to eq("name")
      end

    end

    context "when not persisting" do
      it 'should not rollback all changes' do
        expect(transactor).to be_sleeping
        expect(worker.status).to eq('sleeping')

        # Notice here we're calling "run" and not "run!" with a bang.
        expect {transactor.run}.to raise_error(StandardError, 'failed on purpose')
        expect(transactor).to be_running
        expect(worker.reload.status).to eq('running')
      end

      it 'should not create a database transaction' do
        expect(transactor.class).not_to receive(:transaction)
        expect {transactor.run}.to raise_error(StandardError, 'failed on purpose')
      end
    end
  end
end

describe "invalid states with persistence" do

  it "should not store states" do
    validator = Validator.create(:name => 'name')
    validator.status = 'invalid_state'
    expect(validator.save).to be_false
    expect {validator.save!}.to raise_error(ActiveRecord::RecordInvalid)

    validator.reload
    expect(validator).to be_sleeping
  end

  it "should store invalid states if configured" do
    persistor = InvalidPersistor.create(:name => 'name')
    persistor.status = 'invalid_state'
    expect(persistor.save).to be_true

    persistor.reload
    expect(persistor.status).to eq('invalid_state')
  end

end

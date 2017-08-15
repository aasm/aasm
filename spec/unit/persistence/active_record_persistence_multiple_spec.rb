require 'spec_helper'

if defined?(ActiveRecord)

  Dir[File.dirname(__FILE__) + "/../../models/active_record/*.rb"].sort.each do |f|
    require File.expand_path(f)
  end

  load_schema

  # if you want to see the statements while running the spec enable the following line
  # require 'logger'
  # ActiveRecord::Base.logger = Logger.new(STDERR)

  describe "instance methods" do
    let(:gate) {MultipleGate.new}

    it "should respond to aasm persistence methods" do
      expect(gate).to respond_to(:aasm_read_state)
      expect(gate).to respond_to(:aasm_write_state)
      expect(gate).to respond_to(:aasm_write_state_without_persistence)
    end

    describe "aasm_column_looks_like_enum" do
      subject { lambda{ gate.send(:aasm_column_looks_like_enum, :left) } }

      let(:column_name) { "value" }
      let(:columns_hash) { Hash[column_name, column] }

      before :each do
        allow(gate.class.aasm(:left)).to receive(:attribute_name).and_return(column_name.to_sym)
        allow(gate.class).to receive(:columns_hash).and_return(columns_hash)
      end

      context "when AASM column has integer type" do
        let(:column) { double(Object, type: :integer) }

        it "returns true" do
          expect(subject.call).to be_truthy
        end
      end

      context "when AASM column has string type" do
        let(:column) { double(Object, type: :string) }

        it "returns false" do
          expect(subject.call).to be_falsey
        end
      end
    end

    describe "aasm_guess_enum_method" do
      subject { lambda{ gate.send(:aasm_guess_enum_method, :left) } }

      before :each do
        allow(gate.class.aasm(:left)).to receive(:attribute_name).and_return(:value)
      end

      it "pluralizes AASM column name" do
        expect(subject.call).to eq :values
      end
    end

    describe "aasm_enum" do
      context "when AASM enum setting contains an explicit enum method name" do
        let(:with_enum) { MultipleWithEnum.new }

        it "returns whatever value was set in AASM config" do
          expect(with_enum.send(:aasm_enum, :left)).to eq :test
        end
      end

      context "when AASM enum setting is simply set to true" do
        let(:with_true_enum) { MultipleWithTrueEnum.new }
        before :each do
          allow(MultipleWithTrueEnum.aasm(:left)).to receive(:attribute_name).and_return(:value)
        end

        it "infers enum method name from pluralized column name" do
          expect(with_true_enum.send(:aasm_enum, :left)).to eq :values
        end
      end

      context "when AASM enum setting is explicitly disabled" do
        let(:with_false_enum) { MultipleWithFalseEnum.new }

        it "returns nil" do
          expect(with_false_enum.send(:aasm_enum, :left)).to be_nil
        end
      end

      context "when AASM enum setting is not enabled" do
        before :each do
          allow(MultipleGate.aasm(:left)).to receive(:attribute_name).and_return(:value)
        end

        context "when AASM column looks like enum" do
          before :each do
            allow(gate).to receive(:aasm_column_looks_like_enum).with(:left).and_return(true)
          end

          it "infers enum method name from pluralized column name" do
            expect(gate.send(:aasm_enum, :left)).to eq :values
          end
        end

        context "when AASM column doesn't look like enum'" do
          before :each do
            allow(gate).to receive(:aasm_column_looks_like_enum)
              .and_return(false)
          end

          it "returns nil, as we're not using enum" do
            expect(gate.send(:aasm_enum, :left)).to be_nil
          end
        end
      end

      if ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 1 # won't work with Rails <= 4.1
        # Enum are introduced from Rails 4.1, therefore enum syntax will not work on Rails <= 4.1
        context "when AASM enum setting is not enabled and aasm column not present" do

          let(:multiple_with_enum_without_column) {MultipleWithEnumWithoutColumn.new}

          it "should raise NoMethodError for transitions" do
            expect{multiple_with_enum_without_column.send(:view, :left)}.to raise_error(NoMethodError, /undefined method .status./)
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
        allow(gate).to receive(:aasm_enum).and_return(enum_name)
        allow(gate).to receive(:aasm_write_state_attribute)
        allow(gate).to receive(:write_attribute)

        allow(MultipleGate).to receive(enum_name).and_return(enum)
      end

      describe "aasm_write_state" do
        context "when AASM is configured to skip validations on save" do
          before :each do
            allow(gate).to receive(:aasm_skipping_validations).and_return(true)
          end

          it "passes state code instead of state symbol to update_all" do
            # stub_chain does not allow us to give expectations on call
            # parameters in the middle of the chain, so we need to use
            # intermediate object instead.
            obj = double(Object, update_all: 1)
            allow(MultipleGate).to receive_message_chain(:unscoped, :where)
              .and_return(obj)

            gate.aasm_write_state state_sym, :left

            expect(obj).to have_received(:update_all)
              .with(Hash[gate.class.aasm(:left).attribute_name, state_code])
          end
        end

        context "when AASM is not skipping validations" do
          it "delegates state update to the helper method" do
            # Let's pretend that validation is passed
            allow(gate).to receive(:save).and_return(true)

            gate.aasm_write_state state_sym, :left

            expect(gate).to have_received(:aasm_write_state_attribute).with(state_sym, :left)
            expect(gate).to_not have_received :write_attribute
          end
        end
      end

      describe "aasm_write_state_without_persistence" do
        it "delegates state update to the helper method" do
          gate.aasm_write_state_without_persistence state_sym, :left

          expect(gate).to have_received(:aasm_write_state_attribute).with(state_sym, :left)
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
        allow(gate).to receive(:aasm_enum).and_return(nil)
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
        allow(gate).to receive(:write_attribute)
        allow(gate).to receive(:aasm_raw_attribute_value).and_return(value)

        gate.send(:aasm_write_state_attribute, sym, :left)
      end

      it "generates attribute value using a helper method" do
        expect(gate).to have_received(:aasm_raw_attribute_value).with(sym, :left)
      end

      it "writes attribute to the model" do
        expect(gate).to have_received(:write_attribute).with(:aasm_state, value)
      end
    end

    it "should return the initial state when new and the aasm field is nil" do
      expect(gate.aasm(:left).current_state).to eq(:opened)
    end

    it "should return the aasm column when new and the aasm field is not nil" do
      gate.aasm_state = "closed"
      expect(gate.aasm(:left).current_state).to eq(:closed)
    end

    it "should return the aasm column when not new and the aasm.attribute_name is not nil" do
      allow(gate).to receive(:new_record?).and_return(false)
      gate.aasm_state = "state"
      expect(gate.aasm(:left).current_state).to eq(:state)
    end

    it "should allow a nil state" do
      allow(gate).to receive(:new_record?).and_return(false)
      gate.aasm_state = nil
      expect(gate.aasm(:left).current_state).to be_nil
    end

    context 'on initialization' do
      it "should initialize the aasm state" do
        expect(MultipleGate.new.aasm_state).to eql 'opened'
        expect(MultipleGate.new.aasm(:left).current_state).to eql :opened
      end

      it "should not initialize the aasm state if it has not been loaded" do
        # we have to create a gate in the database, for which we only want to
        # load the id, and not the state
        gate = MultipleGate.create!

        # then we just load the gate ids
        MultipleGate.select(:id).where(id: gate.id).first
      end
    end

  end

  if ActiveRecord::VERSION::MAJOR < 4 && ActiveRecord::VERSION::MINOR < 2 # won't work with Rails >= 4.2
  describe "direct state column access" do
    it "accepts false states" do
      f = MultipleFalseState.create!
      expect(f.aasm_state).to eql false
      expect {
        f.aasm(:left).events.map(&:name)
      }.to_not raise_error
    end
  end
  end

  describe 'subclasses' do
    it "should have the same states as its parent class" do
      expect(MultipleDerivateNewDsl.aasm(:left).states).to eq(MultipleSimpleNewDsl.aasm(:left).states)
    end

    it "should have the same events as its parent class" do
      expect(MultipleDerivateNewDsl.aasm(:left).events).to eq(MultipleSimpleNewDsl.aasm(:left).events)
    end

    it "should have the same column as its parent even for the new dsl" do
      expect(MultipleSimpleNewDsl.aasm(:left).attribute_name).to eq(:status)
      expect(MultipleDerivateNewDsl.aasm(:left).attribute_name).to eq(:status)
    end
  end

  describe "named scopes with the new DSL" do
    context "Does not already respond_to? the scope name" do
      it "should add a scope for each state" do
        expect(MultipleSimpleNewDsl).to respond_to(:unknown_scope)
        expect(MultipleSimpleNewDsl).to respond_to(:another_unknown_scope)

        expect(MultipleSimpleNewDsl.unknown_scope.is_a?(ActiveRecord::Relation)).to be_truthy
        expect(MultipleSimpleNewDsl.another_unknown_scope.is_a?(ActiveRecord::Relation)).to be_truthy
      end
    end

    context "Already respond_to? the scope name" do
      it "should not add a scope" do
        expect(MultipleSimpleNewDsl).to respond_to(:new)
        expect(MultipleSimpleNewDsl.new.class).to eq(MultipleSimpleNewDsl)
      end
    end

    it "does not create scopes if requested" do
      expect(MultipleNoScope).not_to respond_to(:pending)
    end

    context "result of scope" do
      let!(:dsl1) { MultipleSimpleNewDsl.create!(status: :new) }
      let!(:dsl2) { MultipleSimpleNewDsl.create!(status: :unknown_scope) }

      after do
        MultipleSimpleNewDsl.destroy_all
      end

      it "created scope works as where(name: :scope_name)" do
        expect(MultipleSimpleNewDsl.unknown_scope).to contain_exactly(dsl2)
      end
    end
  end # scopes

  describe "direct assignment" do
    it "is allowed by default" do
      obj = MultipleNoScope.create
      expect(obj.aasm_state.to_sym).to eql :pending

      obj.aasm_state = :running
      expect(obj.aasm_state.to_sym).to eql :running
    end

    it "is forbidden if configured" do
      obj = MultipleNoDirectAssignment.create
      expect(obj.aasm_state.to_sym).to eql :pending

      expect {obj.aasm_state = :running}.to raise_error(AASM::NoDirectAssignmentError)
      expect(obj.aasm_state.to_sym).to eql :pending
    end

    it 'can be turned off and on again' do
      obj = MultipleNoDirectAssignment.create
      expect(obj.aasm_state.to_sym).to eql :pending

      expect {obj.aasm_state = :running}.to raise_error(AASM::NoDirectAssignmentError)
      expect(obj.aasm_state.to_sym).to eql :pending

      # allow it temporarily
      MultipleNoDirectAssignment.aasm(:left).state_machine.config.no_direct_assignment = false
      obj.aasm_state = :pending
      expect(obj.aasm_state.to_sym).to eql :pending

      # and forbid it again
      MultipleNoDirectAssignment.aasm(:left).state_machine.config.no_direct_assignment = true
      expect {obj.aasm_state = :running}.to raise_error(AASM::NoDirectAssignmentError)
      expect(obj.aasm_state.to_sym).to eql :pending
    end
  end # direct assignment

  describe 'initial states' do
    it 'should support conditions' do
      expect(MultipleThief.new(:skilled => true).aasm(:left).current_state).to eq(:rich)
      expect(MultipleThief.new(:skilled => false).aasm(:left).current_state).to eq(:jailed)
    end
  end

  describe 'transitions with persistence' do

    it "should work for valid models" do
      valid_object = MultipleValidator.create(:name => 'name')
      expect(valid_object).to be_sleeping
      valid_object.status = :running
      expect(valid_object).to be_running
    end

    it 'should not store states for invalid models' do
      validator = MultipleValidator.create(:name => 'name')
      expect(validator).to be_valid
      expect(validator).to be_sleeping

      validator.name = nil
      expect(validator).not_to be_valid
      expect { validator.run! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(validator).to be_sleeping

      validator.reload
      expect(validator).not_to be_running
      expect(validator).to be_sleeping

      validator.name = 'another name'
      expect(validator).to be_valid
      expect(validator.run!).to be_truthy
      expect(validator).to be_running

      validator.reload
      expect(validator).to be_running
      expect(validator).not_to be_sleeping
    end

    it 'should not store states for invalid models silently if configured' do
      validator = MultipleSilentPersistor.create(:name => 'name')
      expect(validator).to be_valid
      expect(validator).to be_sleeping

      validator.name = nil
      expect(validator).not_to be_valid
      expect(validator.run!).to be_falsey
      expect(validator).to be_sleeping

      validator.reload
      expect(validator).not_to be_running
      expect(validator).to be_sleeping

      validator.name = 'another name'
      expect(validator).to be_valid
      expect(validator.run!).to be_truthy
      expect(validator).to be_running

      validator.reload
      expect(validator).to be_running
      expect(validator).not_to be_sleeping
    end

    it 'should store states for invalid models if configured' do
      persistor = MultipleInvalidPersistor.create(:name => 'name')
      expect(persistor).to be_valid
      expect(persistor).to be_sleeping

      persistor.name = nil
      expect(persistor).not_to be_valid
      expect(persistor.run!).to be_truthy
      expect(persistor).to be_running

      persistor = MultipleInvalidPersistor.find(persistor.id)
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
      let(:transactor) { MultipleTransactor.create!(:name => 'transactor', :worker => worker) }

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
          AASM::StateMachineStore[MultipleTransactor][:left].config.requires_new_transaction = false

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
          validator = MultipleValidator.create(:name => 'name')
          expect(validator).to be_sleeping

          validator.run!
          expect(validator).to be_running
          expect(validator.name).to eq("name changed")

          validator.sleep!("sleeper")
          expect(validator).to be_sleeping
          expect(validator.name).to eq("sleeper")
        end

        it "should not fire :after_commit if transaction failed" do
          validator = MultipleValidator.create(:name => 'name')
          expect { validator.fail! }.to raise_error(StandardError, 'failed on purpose')
          expect(validator.name).to eq("name")
        end

        it "should not fire if not saving" do
          validator = MultipleValidator.create(:name => 'name')
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
      validator = MultipleValidator.create(:name => 'name')
      validator.status = 'invalid_state'
      expect(validator.save).to be_falsey
      expect {validator.save!}.to raise_error(ActiveRecord::RecordInvalid)

      validator.reload
      expect(validator).to be_sleeping
    end

    it "should store invalid states if configured" do
      persistor = MultipleInvalidPersistor.create(:name => 'name')
      persistor.status = 'invalid_state'
      expect(persistor.save).to be_truthy

      persistor.reload
      expect(persistor.status).to eq('invalid_state')
    end
  end

  describe "complex example" do
    it "works" do
      record = ComplexActiveRecordExample.new
      expect_aasm_states record, :one, :alpha

      record.save!
      expect_aasm_states record, :one, :alpha
      record.reload
      expect_aasm_states record, :one, :alpha

      record.increment!
      expect_aasm_states record, :two, :alpha
      record.reload
      expect_aasm_states record, :two, :alpha

      record.level_up!
      expect_aasm_states record, :two, :beta
      record.reload
      expect_aasm_states record, :two, :beta

      record.increment!
      expect { record.increment! }.to raise_error(AASM::InvalidTransition)
      expect_aasm_states record, :three, :beta
      record.reload
      expect_aasm_states record, :three, :beta

      record.level_up!
      expect_aasm_states record, :three, :gamma
      record.reload
      expect_aasm_states record, :three, :gamma

      record.level_down # without saving
      expect_aasm_states record, :three, :beta
      record.reload
      expect_aasm_states record, :three, :gamma

      record.level_down # without saving
      expect_aasm_states record, :three, :beta
      record.reset!
      expect_aasm_states record, :one, :beta
    end

    def expect_aasm_states(record, left_state, right_state)
      expect(record.aasm(:left).current_state).to eql left_state.to_sym
      expect(record.left).to eql left_state.to_s
      expect(record.aasm(:right).current_state).to eql right_state.to_sym
      expect(record.right).to eql right_state.to_s
    end
  end
end

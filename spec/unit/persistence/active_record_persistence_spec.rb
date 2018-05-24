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
        allow(gate.class.aasm).to receive(:attribute_name).and_return(column_name.to_sym)
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
      subject { lambda{ gate.send(:aasm_guess_enum_method) } }

      before :each do
        allow(gate.class.aasm).to receive(:attribute_name).and_return(:value)
      end

      it "pluralizes AASM column name" do
        expect(subject.call).to eq :values
      end
    end

    describe "aasm_enum" do
      context "when AASM enum setting contains an explicit enum method name" do
        let(:with_enum) { WithEnum.new }

        it "returns whatever value was set in AASM config" do
          expect(with_enum.send(:aasm_enum)).to eq :test
        end
      end

      context "when AASM enum setting is simply set to true" do
        let(:with_true_enum) { WithTrueEnum.new }
        before :each do
          allow(WithTrueEnum.aasm).to receive(:attribute_name).and_return(:value)
        end

        it "infers enum method name from pluralized column name" do
          expect(with_true_enum.send(:aasm_enum)).to eq :values
        end
      end

      context "when AASM enum setting is explicitly disabled" do
        let(:with_false_enum) { WithFalseEnum.new }

        it "returns nil" do
          expect(with_false_enum.send(:aasm_enum)).to be_nil
        end
      end

      context "when AASM enum setting is not enabled" do
        before :each do
          allow(Gate.aasm).to receive(:attribute_name).and_return(:value)
        end

        context "when AASM column looks like enum" do
          before :each do
            allow(gate).to receive(:aasm_column_looks_like_enum).and_return(true)
          end

          it "infers enum method name from pluralized column name" do
            expect(gate.send(:aasm_enum)).to eq :values
          end
        end

        context "when AASM column doesn't look like enum'" do
          before :each do
            allow(gate).to receive(:aasm_column_looks_like_enum)
              .and_return(false)
          end

          it "returns nil, as we're not using enum" do
            expect(gate.send(:aasm_enum)).to be_nil
          end
        end
      end

      if ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 1 # won't work with Rails <= 4.1
        # Enum are introduced from Rails 4.1, therefore enum syntax will not work on Rails <= 4.1
        context "when AASM enum setting is not enabled and aasm column not present" do

          let(:with_enum_without_column) {WithEnumWithoutColumn.new}

          it "should raise NoMethodError for transitions" do
            expect{with_enum_without_column.send(:view)}.to raise_error(NoMethodError, /undefined method .status./)
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

        allow(Gate).to receive(enum_name).and_return(enum)
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
            allow(Gate).to receive_message_chain(:unscoped, :where).and_return(obj)

            gate.aasm_write_state state_sym

            expect(obj).to have_received(:update_all)
              .with(Hash[gate.class.aasm.attribute_name, state_code])
          end

          it "searches model outside of default_scope when update_all" do
            # stub_chain does not allow us to give expectations on call
            # parameters in the middle of the chain, so we need to use
            # intermediate object instead.
            unscoped = double(Object, update_all: 1)
            scoped = double(Object, update_all: 1)

            allow(Gate).to receive(:unscoped).and_return(unscoped)
            allow(Gate).to receive(:where).and_return(scoped)
            allow(unscoped).to receive(:where).and_return(unscoped)

            gate.aasm_write_state state_sym

            expect(unscoped).to have_received(:update_all)
              .with(Hash[gate.class.aasm.attribute_name, state_code])
            expect(scoped).to_not have_received(:update_all)
              .with(Hash[gate.class.aasm.attribute_name, state_code])
          end
        end

        context "when AASM is not skipping validations" do
          it "delegates state update to the helper method" do
            # Let's pretend that validation is passed
            allow(gate).to receive(:save).and_return(true)

            gate.aasm_write_state state_sym

            expect(gate).to have_received(:aasm_write_state_attribute).with(state_sym, :default)
            expect(gate).to_not have_received :write_attribute
          end
        end
      end

      describe "aasm_write_state_without_persistence" do
        it "delegates state update to the helper method" do
          gate.aasm_write_state_without_persistence state_sym

          expect(gate).to have_received(:aasm_write_state_attribute).with(state_sym, :default)
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

        gate.send(:aasm_write_state_attribute, sym)
      end

      it "generates attribute value using a helper method" do
        expect(gate).to have_received(:aasm_raw_attribute_value).with(sym, :default)
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

    it "should return the aasm column when not new and the aasm.attribute_name is not nil" do
      allow(gate).to receive(:new_record?).and_return(false)
      gate.aasm_state = "state"
      expect(gate.aasm.current_state).to eq(:state)
    end

    it "should allow a nil state" do
      allow(gate).to receive(:new_record?).and_return(false)
      gate.aasm_state = nil
      expect(gate.aasm.current_state).to be_nil
    end

    context 'on initialization' do
      it "should initialize the aasm state" do
        expect(Gate.new.aasm_state).to eql 'opened'
        expect(Gate.new.aasm.current_state).to eql :opened
      end

      it "should not initialize the aasm state if it has not been loaded" do
        # we have to create a gate in the database, for which we only want to
        # load the id, and not the state
        gate = Gate.create!

        # then we just load the gate ids
        Gate.select(:id).where(id: gate.id).first
      end
    end

  end

  if ActiveRecord::VERSION::MAJOR < 4 && ActiveRecord::VERSION::MINOR < 2 # won't work with Rails >= 4.2
  describe "direct state column access" do
    it "accepts false states" do
      f = FalseState.create!
      expect(f.aasm_state).to eql false
      expect {
        f.aasm.events.map(&:name)
      }.to_not raise_error
    end
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
      expect(SimpleNewDsl.aasm.attribute_name).to eq(:status)
      expect(DerivateNewDsl.aasm.attribute_name).to eq(:status)
    end
  end

  describe "named scopes with the new DSL" do
    context "Does not already respond_to? the scope name" do
      it "should add a scope for each state" do
        expect(SimpleNewDsl).to respond_to(:unknown_scope)
        expect(SimpleNewDsl).to respond_to(:another_unknown_scope)

        expect(SimpleNewDsl.unknown_scope.is_a?(ActiveRecord::Relation)).to be_truthy
        expect(SimpleNewDsl.another_unknown_scope.is_a?(ActiveRecord::Relation)).to be_truthy
      end
    end

    context "Already respond_to? the scope name" do
      it "should not add a scope" do
        expect(SimpleNewDsl).to respond_to(:new)
        expect(SimpleNewDsl.new.class).to eq(SimpleNewDsl)
      end
    end

    # Scopes on abstract classes didn't work until Rails 5.
    #
    # Reference:
    # https://github.com/rails/rails/issues/10658
    if ActiveRecord::VERSION::MAJOR >= 5
      context "For a descendant of an abstract model" do
        it "should add the scope without the table_name" do
          expect(ImplementedAbstractClassDsl).to respond_to(:unknown_scope)
          expect(ImplementedAbstractClassDsl).to respond_to(:another_unknown_scope)

          expect(ImplementedAbstractClassDsl.unknown_scope.is_a?(ActiveRecord::Relation)).to be_truthy
          expect(ImplementedAbstractClassDsl.another_unknown_scope.is_a?(ActiveRecord::Relation)).to be_truthy
        end
      end
    end

    it "does not create scopes if requested" do
      expect(NoScope).not_to respond_to(:pending)
    end

    context "result of scope" do
      let!(:dsl1) { SimpleNewDsl.create!(status: :new) }
      let!(:dsl2) { SimpleNewDsl.create!(status: :unknown_scope) }

      after do
        SimpleNewDsl.destroy_all
      end

      it "created scope works as where(name: :scope_name)" do
        expect(SimpleNewDsl.unknown_scope).to contain_exactly(dsl2)
      end
    end
  end # scopes

  describe "direct assignment" do
    it "is allowed by default" do
      obj = NoScope.create
      expect(obj.aasm_state.to_sym).to eql :pending

      obj.aasm_state = :running
      expect(obj.aasm_state.to_sym).to eql :running
    end

    it "is forbidden if configured" do
      obj = NoDirectAssignment.create
      expect(obj.aasm_state.to_sym).to eql :pending

      expect {obj.aasm_state = :running}.to raise_error(AASM::NoDirectAssignmentError)
      expect(obj.aasm_state.to_sym).to eql :pending
    end

    it 'can be turned off and on again' do
      obj = NoDirectAssignment.create
      expect(obj.aasm_state.to_sym).to eql :pending

      expect {obj.aasm_state = :running}.to raise_error(AASM::NoDirectAssignmentError)
      expect(obj.aasm_state.to_sym).to eql :pending

      # allow it temporarily
      NoDirectAssignment.aasm.state_machine.config.no_direct_assignment = false
      obj.aasm_state = :pending
      expect(obj.aasm_state.to_sym).to eql :pending

      # and forbid it again
      NoDirectAssignment.aasm.state_machine.config.no_direct_assignment = true
      expect {obj.aasm_state = :running}.to raise_error(AASM::NoDirectAssignmentError)
      expect(obj.aasm_state.to_sym).to eql :pending
    end
  end # direct assignment

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
      validator = SilentPersistor.create(:name => 'name')
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
      persistor = InvalidPersistor.create(:name => 'name')
      expect(persistor).to be_valid
      expect(persistor).to be_sleeping

      persistor.name = nil
      expect(persistor).not_to be_valid
      expect(persistor.run!).to be_truthy
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

    describe 'pessimistic locking' do
      let(:worker) { Worker.create!(:name => 'worker', :status => 'sleeping') }

      subject { transactor.run! }

      context 'no lock' do
        let(:transactor) { NoLockTransactor.create!(:name => 'no_lock_transactor', :worker => worker) }

        it 'should not invoke lock!' do
          expect(transactor).to_not receive(:lock!)
          subject
        end
      end

      context 'a default lock' do
        let(:transactor) { LockTransactor.create!(:name => 'lock_transactor', :worker => worker) }

        it 'should invoke lock! with true' do
          expect(transactor).to receive(:lock!).with(true).and_call_original
          subject
        end
      end

      context 'a FOR UPDATE NOWAIT lock' do
        let(:transactor) { LockNoWaitTransactor.create!(:name => 'lock_no_wait_transactor', :worker => worker) }

        it 'should invoke lock! with FOR UPDATE NOWAIT' do
          expect(transactor).to receive(:lock!).with('FOR UPDATE NOWAIT').and_call_original
          subject
        end
      end
    end

    describe 'without transactions' do
      let(:worker) { Worker.create!(:name => 'worker', :status => 'sleeping') }
      let(:no_transactor) { NoTransactor.create!(:name => 'transactor', :worker => worker) }

      it 'should not rollback all changes' do
        expect(no_transactor).to be_sleeping
        expect(worker.status).to eq('sleeping')

        expect {no_transactor.run!}.to raise_error(StandardError, 'failed on purpose')
        expect(no_transactor).to be_running
        expect(worker.reload.status).to eq('running')
      end
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
          AASM::StateMachineStore[Transactor][:default].config.requires_new_transaction = false

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
          expect(validator.name).to eq("name changed")

          validator.sleep!("sleeper")
          expect(validator).to be_sleeping
          expect(validator.name).to eq("sleeper")
        end

        it "should not fire :after_commit if transaction failed" do
          validator = Validator.create(:name => 'name')
          expect { validator.fail! }.to raise_error(StandardError, 'failed on purpose')
          expect(validator.name).to eq("name")
        end

        it "should not fire :after_commit if validation failed when saving object" do
          validator = Validator.create(:name => 'name')
          validator.invalid = true
          expect { validator.run! }.to raise_error(ActiveRecord::RecordInvalid, 'Invalid record')
          expect(validator).to be_sleeping
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

      describe 'before and after transaction callbacks' do
        [:after, :before].each do |event_type|
          describe "#{event_type}_transaction callback" do
            it "should fire :#{event_type}_transaction if transaction was successful" do
              validator = Validator.create(:name => 'name')
              expect(validator).to be_sleeping

              expect { validator.run! }.to change { validator.send("#{event_type}_transaction_performed_on_run") }.from(nil).to(true)
              expect(validator).to be_running
            end

            it "should fire :#{event_type}_transaction if transaction failed" do
              validator = Validator.create(:name => 'name')
              expect do
                begin
                  validator.fail!
                rescue => ignored
                end
              end.to change { validator.send("#{event_type}_transaction_performed_on_fail") }.from(nil).to(true)
              expect(validator).to_not be_running
            end

            it "should not fire :#{event_type}_transaction if not saving" do
              validator = Validator.create(:name => 'name')
              expect(validator).to be_sleeping
              expect { validator.run }.to_not change { validator.send("#{event_type}_transaction_performed_on_run") }
              expect(validator).to be_running
              expect(validator.name).to eq("name")
            end
          end
        end
      end

      describe 'before and after all transactions callbacks' do
        [:after, :before].each do |event_type|
          describe "#{event_type}_all_transactions callback" do
            it "should fire :#{event_type}_all_transactions if transaction was successful" do
              validator = Validator.create(:name => 'name')
              expect(validator).to be_sleeping

              expect { validator.run! }.to change { validator.send("#{event_type}_all_transactions_performed") }.from(nil).to(true)
              expect(validator).to be_running
            end

            it "should fire :#{event_type}_all_transactions if transaction failed" do
              validator = Validator.create(:name => 'name')
              expect do
                begin
                  validator.fail!
                rescue => ignored
                end
              end.to change { validator.send("#{event_type}_all_transactions_performed") }.from(nil).to(true)
              expect(validator).to_not be_running
            end

            it "should not fire :#{event_type}_all_transactions if not saving" do
              validator = Validator.create(:name => 'name')
              expect(validator).to be_sleeping
              expect { validator.run }.to_not change { validator.send("#{event_type}_all_transactions_performed") }
              expect(validator).to be_running
              expect(validator.name).to eq("name")
            end
          end
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
      expect(validator.save).to be_falsey
      expect {validator.save!}.to raise_error(ActiveRecord::RecordInvalid)

      validator.reload
      expect(validator).to be_sleeping
    end

    it "should store invalid states if configured" do
      persistor = InvalidPersistor.create(:name => 'name')
      persistor.status = 'invalid_state'
      expect(persistor.save).to be_truthy

      persistor.reload
      expect(persistor.status).to eq('invalid_state')
    end

  end

  describe 'basic example with two state machines' do
    let(:example) { BasicActiveRecordTwoStateMachinesExample.new }

    it 'should initialise properly' do
      expect(example.aasm(:search).current_state).to eql :initialised
      expect(example.aasm(:sync).current_state).to eql :unsynced
    end
  end

  describe 'testing the README examples' do
    it 'Usage' do
      job = ReadmeJob.new

      expect(job.sleeping?).to eql true
      expect(job.may_run?).to eql true

      job.run

      expect(job.running?).to eql true
      expect(job.sleeping?).to eql false
      expect(job.may_run?).to eql false

      expect { job.run }.to raise_error(AASM::InvalidTransition)
    end
  end
end

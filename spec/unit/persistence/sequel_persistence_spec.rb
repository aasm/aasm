require 'spec_helper'
if defined?(Sequel)
  describe 'sequel' do

    Dir[File.dirname(__FILE__) + "/../../models/sequel/*.rb"].sort.each do |f|
      require File.expand_path(f)
    end

    before(:all) do
      @model = Sequel::Simple
    end

    describe "instance methods" do
      let(:model) {@model.new}

      it "should respond to aasm persistence methods" do
        expect(model).to respond_to(:aasm_read_state)
        expect(model).to respond_to(:aasm_write_state)
        expect(model).to respond_to(:aasm_write_state_without_persistence)
      end

      it "should return the initial state when new and the aasm field is nil" do
        expect(model.aasm.current_state).to eq(:alpha)
      end

      it "should save the initial state" do
        model.save
        expect(model.status).to eq("alpha")
      end

      it "should return the aasm column when new and the aasm field is not nil" do
        model.status = "beta"
        expect(model.aasm.current_state).to eq(:beta)
      end

      it "should return the aasm column when not new and the aasm_column is not nil" do
        allow(model).to receive(:new?).and_return(false)
        model.status = "gamma"
        expect(model.aasm.current_state).to eq(:gamma)
      end

      it "should allow a nil state" do
        allow(model).to receive(:new?).and_return(false)
        model.status = nil
        expect(model.aasm.current_state).to be_nil
      end

      it "should not change the state if state is not loaded" do
        model.release
        model.save
        model.class.select(:id).first.save
        model.reload
        expect(model.aasm.current_state).to eq(:beta)
      end

      it "should call aasm_ensure_initial_state on validation before create" do
        expect(model).to receive(:aasm_ensure_initial_state).and_return(true)
        model.valid?
      end

      it "should call aasm_ensure_initial_state before create, even if skipping validations" do
        expect(model).to receive(:aasm_ensure_initial_state).and_return(true)
        model.save(:validate => false)
      end
    end

    describe 'subclasses' do
      it "should have the same states as its parent class" do
        expect(Class.new(@model).aasm.states).to eq(@model.aasm.states)
      end

      it "should have the same events as its parent class" do
        expect(Class.new(@model).aasm.events).to eq(@model.aasm.events)
      end

      it "should have the same column as its parent even for the new dsl" do
        expect(@model.aasm.attribute_name).to eq(:status)
        expect(Class.new(@model).aasm.attribute_name).to eq(:status)
      end
    end

    describe 'initial states' do
      it 'should support conditions' do
        @model.aasm do
          initial_state lambda{ |m| m.default }
        end

        expect(@model.new(:default => :beta).aasm.current_state).to eq(:beta)
        expect(@model.new(:default => :gamma).aasm.current_state).to eq(:gamma)
      end
    end

    describe 'transitions with persistence' do

      it "should work for valid models" do
        valid_object = Sequel::Validator.create(:name => 'name')
        expect(valid_object).to be_sleeping
        valid_object.status = :running
        expect(valid_object).to be_running
      end

      it 'should not store states for invalid models' do
        validator = Sequel::Validator.create(:name => 'name')
        expect(validator).to be_valid
        expect(validator).to be_sleeping

        validator.name = nil
        expect(validator).not_to be_valid
        expect { validator.run! }.to raise_error(Sequel::ValidationFailed)
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
        validator = Sequel::SilentPersistor.create(:name => 'name')
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
        persistor = Sequel::InvalidPersistor.create(:name => 'name')
        expect(persistor).to be_valid
        expect(persistor).to be_sleeping

        persistor.name = nil
        expect(persistor).not_to be_valid
        expect(persistor.run!).to be_truthy
        expect(persistor).to be_running

        persistor = Sequel::InvalidPersistor[persistor.id]
        persistor.valid?
        expect(persistor).to be_valid
        expect(persistor).to be_running
        expect(persistor).not_to be_sleeping

        persistor.reload
        expect(persistor).to be_running
        expect(persistor).not_to be_sleeping
      end

      describe 'pessimistic locking' do
        let(:worker) { Sequel::Worker.create(:name => 'worker', :status => 'sleeping') }

        subject { transactor.run! }

        context 'no lock' do
          let(:transactor) { Sequel::NoLockTransactor.create(:name => 'no_lock_transactor', :worker => worker) }

          it 'should not invoke lock!' do
            expect(transactor).to_not receive(:lock!)
            subject
          end
        end

        context 'a default lock' do
          let(:transactor) { Sequel::LockTransactor.create(:name => 'lock_transactor', :worker => worker) }

          it 'should invoke lock!' do
            expect(transactor).to receive(:lock!).and_call_original
            subject
          end
        end

        context 'a FOR UPDATE NOWAIT lock' do
          let(:transactor) { Sequel::LockNoWaitTransactor.create(:name => 'lock_no_wait_transactor', :worker => worker) }

          it 'should invoke lock! with FOR UPDATE NOWAIT' do
            # TODO: With and_call_original, get an error with syntax, should look into it.
            expect(transactor).to receive(:lock!).with('FOR UPDATE NOWAIT')# .and_call_original
            subject
          end
        end
      end

      describe 'transactions' do
        let(:worker) { Sequel::Worker.create(:name => 'worker', :status => 'sleeping') }
        let(:transactor) { Sequel::Transactor.create(:name => 'transactor', :worker => worker) }

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

            Sequel::Worker.db.transaction do
              expect { transactor.run! }.to raise_error(StandardError, 'failed on purpose')
            end

            expect(transactor).to be_running
            expect(worker.reload.status).to eq('sleeping')
          end

          it "should only rollback changes in the main transaction not the nested one" do
            # change configuration to not require new transaction
            AASM::StateMachineStore[Sequel::Transactor][:default].config.requires_new_transaction = false

            expect(transactor).to be_sleeping
            expect(worker.status).to eq('sleeping')
            Sequel::Worker.db.transaction do
              expect { transactor.run! }.to raise_error(StandardError, 'failed on purpose')
            end
            expect(transactor).to be_running
            expect(worker.reload.status).to eq('running')
          end
        end

        describe "after_commit callback" do
          it "should fire :after_commit if transaction was successful" do
            validator = Sequel::Validator.create(:name => 'name')
            expect(validator).to be_sleeping

            validator.run!
            expect(validator).to be_running
            expect(validator.name).to eq("name changed")

            validator.sleep!("sleeper")
            expect(validator).to be_sleeping
            expect(validator.name).to eq("sleeper")
          end

          it "should not fire :after_commit if transaction failed" do
            validator = Sequel::Validator.create(:name => 'name')
            expect { validator.fail! }.to raise_error(StandardError, 'failed on purpose')
            expect(validator.name).to eq("name")
          end

          it "should not fire :after_commit if validation failed when saving object" do
            validator = Sequel::Validator.create(:name => 'name')
            validator.invalid = true
            expect { validator.run! }.to raise_error(Sequel::ValidationFailed, 'validator invalid')
            expect(validator).to be_sleeping
            expect(validator.name).to eq("name")
          end

          it "should not fire if not saving" do
            validator = Sequel::Validator.create(:name => 'name')
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
                validator = Sequel::Validator.create(:name => 'name')
                expect(validator).to be_sleeping

                expect { validator.run! }.to change { validator.send("#{event_type}_transaction_performed_on_run") }.from(nil).to(true)
                expect(validator).to be_running
              end

              it "should fire :#{event_type}_transaction if transaction failed" do
                validator = Sequel::Validator.create(:name => 'name')
                expect do
                  begin
                    validator.fail!
                  rescue => ignored
                  end
                end.to change { validator.send("#{event_type}_transaction_performed_on_fail") }.from(nil).to(true)
                expect(validator).to_not be_running
              end

              it "should not fire :#{event_type}_transaction if not saving" do
                validator = Sequel::Validator.create(:name => 'name')
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
                validator = Sequel::Validator.create(:name => 'name')
                expect(validator).to be_sleeping

                expect { validator.run! }.to change { validator.send("#{event_type}_all_transactions_performed") }.from(nil).to(true)
                expect(validator).to be_running
              end

              it "should fire :#{event_type}_all_transactions if transaction failed" do
                validator = Sequel::Validator.create(:name => 'name')
                expect do
                  begin
                    validator.fail!
                  rescue => ignored
                  end
                end.to change { validator.send("#{event_type}_all_transactions_performed") }.from(nil).to(true)
                expect(validator).to_not be_running
              end

              it "should not fire :#{event_type}_all_transactions if not saving" do
                validator = Sequel::Validator.create(:name => 'name')
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

  end
end

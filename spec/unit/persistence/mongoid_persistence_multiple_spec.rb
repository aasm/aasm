require 'spec_helper'

if defined?(Mongoid::Document)
  describe 'mongoid' do

    Dir[File.dirname(__FILE__) + "/../../models/mongoid/*.rb"].sort.each do |f|
      require File.expand_path(f)
    end

    before(:all) do
      # if you want to see the statements while running the spec enable the following line
      # Mongoid.logger = Logger.new(STDERR)

      Mongoid.configure do |config|
        config.connect_to "mongoid_#{Process.pid}"
      end
    end

    after do
      Mongoid.purge!
    end

    describe "named scopes with the old DSL" do

      context "Does not already respond_to? the scope name" do
        it "should add a scope for each state" do
          expect(SimpleMongoidMultiple).to respond_to(:unknown_scope)
          expect(SimpleMongoidMultiple).to respond_to(:another_unknown_scope)

          expect(SimpleMongoidMultiple.unknown_scope.class).to eq(Mongoid::Criteria)
          expect(SimpleMongoidMultiple.another_unknown_scope.class).to eq(Mongoid::Criteria)
        end
      end

      context "Already respond_to? the scope name" do
        it "should not add a scope" do
          expect(SimpleMongoidMultiple).to respond_to(:new)
          expect(SimpleMongoidMultiple.new.class).to eq(SimpleMongoidMultiple)
        end
      end

    end

    describe "named scopes with the new DSL" do
      context "Does not already respond_to? the scope name" do
        it "should add a scope" do
          expect(SimpleNewDslMongoidMultiple).to respond_to(:unknown_scope)
          expect(SimpleNewDslMongoidMultiple.unknown_scope.class).to eq(Mongoid::Criteria)
        end
      end

      context "Already respond_to? the scope name" do
        it "should not add a scope" do
          expect(SimpleNewDslMongoidMultiple).to respond_to(:new)
          expect(SimpleNewDslMongoidMultiple.new.class).to eq(SimpleNewDslMongoidMultiple)
        end
      end

      it "does not create scopes if requested" do
        expect(NoScopeMongoidMultiple).not_to respond_to(:ignored_scope)
      end
    end

    describe "instance methods" do
      let(:simple) {SimpleNewDslMongoidMultiple.new}

      it "should initialize the aasm state on instantiation" do
        expect(SimpleNewDslMongoidMultiple.new.status).to eql 'unknown_scope'
        expect(SimpleNewDslMongoidMultiple.new.aasm(:left).current_state).to eql :unknown_scope
      end

    end

    describe 'transitions with persistence' do

      it "should work for valid models" do
        valid_object = MultipleValidatorMongoid.create(:name => 'name')
        expect(valid_object).to be_sleeping
        valid_object.status = :running
        expect(valid_object).to be_running
      end

      it 'should not store states for invalid models' do
        validator = MultipleValidatorMongoid.create(:name => 'name')
        expect(validator).to be_valid
        expect(validator).to be_sleeping

        validator.name = nil
        expect(validator).not_to be_valid
        expect { validator.run! }.to raise_error(Mongoid::Errors::Validations)
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
        validator = MultipleSilentPersistorMongoid.create(:name => 'name')
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
        persistor = MultipleInvalidPersistorMongoid.create(:name => 'name')
        expect(persistor).to be_valid
        expect(persistor).to be_sleeping

        persistor.name = nil
        expect(persistor).not_to be_valid
        expect(persistor.run!).to be_truthy
        expect(persistor).to be_running

        persistor = MultipleInvalidPersistorMongoid.find(persistor.id)
        persistor.valid?
        expect(persistor).to be_valid
        expect(persistor).to be_running
        expect(persistor).not_to be_sleeping

        persistor.reload
        expect(persistor).to be_running
        expect(persistor).not_to be_sleeping
      end
    end

    describe "complex example" do
      it "works" do
        record = ComplexMongoidExample.new
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
end

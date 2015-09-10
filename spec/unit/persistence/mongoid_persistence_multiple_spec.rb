describe 'mongoid' do
  begin
    require 'mongoid'
    require 'logger'
    require 'spec_helper'

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
        it "should add a scope" do
          expect(SimpleMongoidMultiple).to respond_to(:unknown_scope)
          expect(SimpleMongoidMultiple.unknown_scope.class).to eq(Mongoid::Criteria)
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

  rescue LoadError
    puts "--------------------------------------------------------------------------"
    puts "Not running Mongoid multiple-specs because mongoid gem is not installed!!!"
    puts "--------------------------------------------------------------------------"
  end
end

describe 'mongo_mapper' do
  begin
    require 'mongo_mapper'
    require 'logger'
    require 'spec_helper'

    Dir[File.dirname(__FILE__) + "/../../models/mongo_mapper/*.rb"].sort.each do |f|
      require File.expand_path(f)
    end

    before(:all) do
      config = {
        'test' => {
          'database' => "mongo_mapper_#{Process.pid}"
        }
      }

      MongoMapper.setup(config, 'test') #, :logger => Logger.new(STDERR))
    end

    after do
      # Clear Out all non-system Mongo collections between tests
      MongoMapper.database.collections.each do |collection|
        collection.drop unless collection.capped? || (collection.name =~ /\Asystem/)
      end
    end

    describe "named scopes with the old DSL" do

      context "Does not already respond_to? the scope name" do
        it "should add a scope" do
          expect(SimpleMongoMapperMultiple).to respond_to(:unknown_scope)
          expect(SimpleMongoMapperMultiple.unknown_scope.class).to eq(MongoMapper::Plugins::Querying::DecoratedPluckyQuery)
          #expect(SimpleMongoMapperMultiple.unknown_scope.is_a?(ActiveRecord::Relation)).to be_truthy
        end
      end

      context "Already respond_to? the scope name" do
        it "should not add a scope" do
          expect(SimpleMongoMapperMultiple).to respond_to(:next)
          expect(SimpleMongoMapperMultiple.new.class).to eq(SimpleMongoMapperMultiple)
        end
      end

    end

    describe "named scopes with the new DSL" do

      context "Does not already respond_to? the scope name" do
        it "should add a scope" do
          expect(SimpleNewDslMongoMapperMultiple).to respond_to(:unknown_scope)
          expect(SimpleNewDslMongoMapperMultiple.unknown_scope.class).to eq(MongoMapper::Plugins::Querying::DecoratedPluckyQuery)
        end
      end

      context "Already respond_to? the scope name" do
        it "should not add a scope" do
          expect(SimpleNewDslMongoMapperMultiple).to respond_to(:next)
          expect(SimpleNewDslMongoMapperMultiple.new.class).to eq(SimpleNewDslMongoMapperMultiple)
        end
      end

      it "does not create scopes if requested" do
        expect(NoScopeMongoMapperMultiple).not_to respond_to(:ignored_scope)
      end

    end

    describe "instance methods" do

      let(:simple) {SimpleNewDslMongoMapperMultiple.new}

      it "should call aasm_ensure_initial_state on validation before create" do
        expect(SimpleNewDslMongoMapperMultiple.aasm(:left).initial_state).to eq(:unknown_scope)
        expect(SimpleNewDslMongoMapperMultiple.aasm(:left).attribute_name).to eq(:status)
        expect(simple.status).to eq(nil)
        simple.valid?
        expect(simple.status).to eq('unknown_scope')
      end

      it "should call aasm_ensure_initial_state before create, even if skipping validations" do
        expect(simple.status).to eq(nil)
        simple.save(:validate => false)
        expect(simple.status).to eq('unknown_scope')
      end
    end

    describe "complex example" do
      it "works" do
        record = ComplexMongoMapperExample.new
        expect(record.aasm(:left).current_state).to eql :one
        expect(record.left).to be_nil
        expect(record.aasm(:right).current_state).to eql :alpha
        expect(record.right).to be_nil

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
    puts "Not running MongoMapper specs because mongo_mapper gem is not installed!!!"
    puts "--------------------------------------------------------------------------"
  end
end

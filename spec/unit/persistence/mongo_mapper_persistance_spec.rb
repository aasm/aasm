describe 'mongo_mapper' do
  begin
    require 'mongo_mapper'
    require 'logger'
    require 'spec_helper'

    before(:all) do
      Dir[File.dirname(__FILE__) + "/../../models/mongo_mapper/*.rb"].sort.each { |f| require File.expand_path(f) }

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
          expect(SimpleMongoMapper).to respond_to(:unknown_scope)
          expect(SimpleMongoMapper.unknown_scope.class).to eq(MongoMapper::Plugins::Querying::DecoratedPluckyQuery)
          #expect(SimpleMongoMapper.unknown_scope.is_a?(ActiveRecord::Relation)).to be_truthy
        end
      end

      context "Already respond_to? the scope name" do
        it "should not add a scope" do
          expect(SimpleMongoMapper).to respond_to(:next)
          expect(SimpleMongoMapper.new.class).to eq(SimpleMongoMapper)
        end
      end

    end

    describe "named scopes with the new DSL" do

      context "Does not already respond_to? the scope name" do
        it "should add a scope" do
          expect(SimpleNewDslMongoMapper).to respond_to(:unknown_scope)
          expect(SimpleNewDslMongoMapper.unknown_scope.class).to eq(MongoMapper::Plugins::Querying::DecoratedPluckyQuery)
        end
      end

      context "Already respond_to? the scope name" do
        it "should not add a scope" do
          expect(SimpleNewDslMongoMapper).to respond_to(:next)
          expect(SimpleNewDslMongoMapper.new.class).to eq(SimpleNewDslMongoMapper)
        end
      end

      it "does not create scopes if requested" do
        expect(NoScopeMongoMapper).not_to respond_to(:ignored_scope)
      end

    end

    describe "#find_in_state" do

      let!(:model)    { SimpleNewDslMongoMapper.create!(:status => :unknown_scope) }
      let!(:model_id) { model._id }

      it "should respond to method" do
        expect(SimpleNewDslMongoMapper).to respond_to(:find_in_state)
      end

      it "should find the model when given the correct scope and model id" do
        expect(SimpleNewDslMongoMapper.find_in_state(model_id, 'unknown_scope').class).to eq(SimpleNewDslMongoMapper)
        expect(SimpleNewDslMongoMapper.find_in_state(model_id, 'unknown_scope')).to eq(model)
      end

      it "should raise DocumentNotFound error when given incorrect scope" do
        expect {SimpleNewDslMongoMapper.find_in_state(model_id, 'next')}.to raise_error MongoMapper::DocumentNotFound
      end

      it "should raise DocumentNotFound error when given incorrect model id" do
        expect {SimpleNewDslMongoMapper.find_in_state('bad_id', 'unknown_scope')}.to raise_error MongoMapper::DocumentNotFound
      end

    end

    describe "#count_in_state" do

      before do
        3.times { SimpleNewDslMongoMapper.create!(:status => :unknown_scope) }
      end

      it "should respond to method" do
        expect(SimpleNewDslMongoMapper).to respond_to(:count_in_state)
      end

      it "should return n for a scope with n records persisted" do
        expect(SimpleNewDslMongoMapper.count_in_state('unknown_scope').class).to eq(Fixnum)
        expect(SimpleNewDslMongoMapper.count_in_state('unknown_scope')).to eq(3)
      end

      it "should return zero for a scope without records persisted" do
        expect(SimpleNewDslMongoMapper.count_in_state('next').class).to eq(Fixnum)
        expect(SimpleNewDslMongoMapper.count_in_state('next')).to eq(0)
      end

    end

    describe "instance methods" do

      let(:simple) {SimpleNewDslMongoMapper.new}

      it "should call aasm_ensure_initial_state on validation before create" do
        expect(SimpleNewDslMongoMapper.aasm.initial_state).to eq(:unknown_scope)
        expect(SimpleNewDslMongoMapper.aasm.attribute_name).to eq(:status)
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

  rescue LoadError
    puts "Not running MongoMapper specs because mongo_mapper gem is not installed!!!"
  end
end

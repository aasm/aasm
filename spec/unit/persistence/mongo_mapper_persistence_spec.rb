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
    puts "--------------------------------------------------------------------------"
    puts "Not running MongoMapper multiple-specs because mongo_mapper gem is not installed!!!"
    puts "--------------------------------------------------------------------------"
  end
end

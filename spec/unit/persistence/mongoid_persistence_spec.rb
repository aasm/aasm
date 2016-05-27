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
          expect(SimpleMongoid).to respond_to(:unknown_scope)
          expect(SimpleMongoid.unknown_scope.class).to eq(Mongoid::Criteria)
        end
      end

      context "Already respond_to? the scope name" do
        it "should not add a scope" do
          expect(SimpleMongoid).to respond_to(:new)
          expect(SimpleMongoid.new.class).to eq(SimpleMongoid)
        end
      end

    end

    describe "named scopes with the new DSL" do

      context "Does not already respond_to? the scope name" do
        it "should add a scope" do
          expect(SimpleNewDslMongoid).to respond_to(:unknown_scope)
          expect(SimpleNewDslMongoid.unknown_scope.class).to eq(Mongoid::Criteria)
        end
      end

      context "Already respond_to? the scope name" do
        it "should not add a scope" do
          expect(SimpleNewDslMongoid).to respond_to(:new)
          expect(SimpleNewDslMongoid.new.class).to eq(SimpleNewDslMongoid)
        end
      end

      it "does not create scopes if requested" do
        expect(NoScopeMongoid).not_to respond_to(:ignored_scope)
      end

    end

    describe "instance methods" do
      let(:simple) {SimpleNewDslMongoid.new}

      it "should initialize the aasm state on instantiation" do
        expect(SimpleNewDslMongoid.new.status).to eql 'unknown_scope'
        expect(SimpleNewDslMongoid.new.aasm.current_state).to eql :unknown_scope
      end

    end

    describe "relations object" do

      it "should load relations object ids" do
        parent  =  Parent.create
        child_1 = Child.create(parent_id: parent.id)
        child_2 = Child.create(parent_id: parent.id)
        expect(parent.child_ids).to eql [child_1.id, child_2.id]
      end

    end

  rescue LoadError
    puts "--------------------------------------------------------------------------"
    puts "Not running Mongoid specs because mongoid gem is not installed!!!"
    puts "--------------------------------------------------------------------------"
  end
end

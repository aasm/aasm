describe 'mongoid' do
  begin
    require 'mongoid'
    require 'logger'
    require 'spec_helper'

    before(:all) do
      Dir[File.dirname(__FILE__) + "/../../models/mongoid/*.rb"].sort.each do |f|
        require File.expand_path(f)
      end

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

  rescue LoadError
    puts "Not running Mongoid specs because mongoid gem is not installed!!!"
  end
end

describe 'mongoid', :if => Gem::Version.create(RUBY_VERSION.dup) >= Gem::Version.create('1.9.3') do
# describe 'mongoid' do

  begin
    require 'mongoid'
    require 'logger'
    require 'spec_helper'

    before(:all) do
      Dir[File.dirname(__FILE__) + "/../../models/mongoid/*.rb"].sort.each { |f| require File.expand_path(f) }

      # if you want to see the statements while running the spec enable the following line
      # Mongoid.logger = Logger.new(STDERR)

      DATABASE_NAME = "mongoid_#{Process.pid}"

      Mongoid.configure do |config|
        config.connect_to DATABASE_NAME
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

    describe "#find_in_state" do

      let!(:model)    { SimpleNewDslMongoid.create!(:status => :unknown_scope) }
      let!(:model_id) { model._id }

      it "should respond to method" do
        expect(SimpleNewDslMongoid).to respond_to(:find_in_state)
      end

      it "should find the model when given the correct scope and model id" do
        expect(SimpleNewDslMongoid.find_in_state(model_id, 'unknown_scope').class).to eq(SimpleNewDslMongoid)
        expect(SimpleNewDslMongoid.find_in_state(model_id, 'unknown_scope')).to eq(model)
      end

      it "should raise DocumentNotFound error when given incorrect scope" do
        expect {SimpleNewDslMongoid.find_in_state(model_id, 'new')}.to raise_error Mongoid::Errors::DocumentNotFound
      end

      it "should raise DocumentNotFound error when given incorrect model id" do
        expect {SimpleNewDslMongoid.find_in_state('bad_id', 'unknown_scope')}.to raise_error Mongoid::Errors::DocumentNotFound
      end

    end

    describe "#count_in_state" do

      before do
        3.times { SimpleNewDslMongoid.create!(:status => :unknown_scope) }
      end

      it "should respond to method" do
        expect(SimpleNewDslMongoid).to respond_to(:count_in_state)
      end

      it "should return n for a scope with n records persisted" do
        expect(SimpleNewDslMongoid.count_in_state('unknown_scope').class).to eq(Fixnum)
        expect(SimpleNewDslMongoid.count_in_state('unknown_scope')).to eq(3)
      end

      it "should return zero for a scope without records persisted" do
        expect(SimpleNewDslMongoid.count_in_state('new').class).to eq(Fixnum)
        expect(SimpleNewDslMongoid.count_in_state('new')).to eq(0)
      end

    end

    describe "#with_state_scope" do

      before do
        3.times { SimpleNewDslMongoid.create!(:status => :unknown_scope) }
        2.times { SimpleNewDslMongoid.create!(:status => :new) }
      end

      it "should respond to method" do
        expect(SimpleNewDslMongoid).to respond_to(:with_state_scope)
      end

      it "should correctly process block" do
        expect(SimpleNewDslMongoid.with_state_scope('unknown_scope') do
          SimpleNewDslMongoid.count
        end).to eq(3)
        expect(SimpleNewDslMongoid.with_state_scope('new') do
          SimpleNewDslMongoid.count
        end).to eq(2)
      end

    end


    describe "instance methods" do
      let(:simple) {SimpleNewDslMongoid.new}

      it "should call aasm_ensure_initial_state on validation before create" do
        expect(simple).to receive(:aasm_ensure_initial_state).and_return(true)
        simple.valid?
      end

      it "should call aasm_ensure_initial_state before create, even if skipping validations" do
        expect(simple).to receive(:aasm_ensure_initial_state).and_return(true)
        simple.save(:validate => false)
      end
    end

  rescue LoadError
    puts "Not running Mongoid specs because mongoid gem is not installed!!!"
  end
end

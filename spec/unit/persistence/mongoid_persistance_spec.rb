describe 'mongoid', :if => Gem::Version.create(RUBY_VERSION.dup) >= Gem::Version.create('1.9.3') do

  before(:all) do
    require 'mongoid'
    require 'logger'
    require 'spec_helper'
    require File.dirname(__FILE__) + '/../../models/mongoid/mongoid_models'

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
        SimpleMongoid.should respond_to(:unknown_scope)
        SimpleMongoid.unknown_scope.class.should == Mongoid::Criteria
      end
    end

    context "Already respond_to? the scope name" do
      it "should not add a scope" do
        SimpleMongoid.should respond_to(:new)
        SimpleMongoid.new.class.should == SimpleMongoid
      end
    end

  end

  describe "named scopes with the new DSL" do

    context "Does not already respond_to? the scope name" do
      it "should add a scope" do
        SimpleNewDslMongoid.should respond_to(:unknown_scope)
        SimpleNewDslMongoid.unknown_scope.class.should == Mongoid::Criteria
      end
    end

    context "Already respond_to? the scope name" do
      it "should not add a scope" do
        SimpleNewDslMongoid.should respond_to(:new)
        SimpleNewDslMongoid.new.class.should == SimpleNewDslMongoid
      end
    end

  end

  describe "#find_in_state" do

    let!(:model)    { SimpleNewDslMongoid.create!(:status => :unknown_scope) }
    let!(:model_id) { model._id }

    it "should respond to method" do
      SimpleNewDslMongoid.should respond_to(:find_in_state)
    end

    it "should find the model when given the correct scope and model id" do
      SimpleNewDslMongoid.find_in_state(model_id, 'unknown_scope').class.should == SimpleNewDslMongoid
      SimpleNewDslMongoid.find_in_state(model_id, 'unknown_scope').should == model
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
      SimpleNewDslMongoid.should respond_to(:count_in_state)
    end

    it "should return n for a scope with n records persisted" do
      SimpleNewDslMongoid.count_in_state('unknown_scope').class.should == Fixnum
      SimpleNewDslMongoid.count_in_state('unknown_scope').should == 3
    end

    it "should return zero for a scope without records persisted" do
      SimpleNewDslMongoid.count_in_state('new').class.should == Fixnum
      SimpleNewDslMongoid.count_in_state('new').should == 0
    end

  end

  describe "#with_state_scope" do

    before do
      3.times { SimpleNewDslMongoid.create!(:status => :unknown_scope) }
      2.times { SimpleNewDslMongoid.create!(:status => :new) }
    end

    it "should respond to method" do
      SimpleNewDslMongoid.should respond_to(:with_state_scope)
    end

    it "should correctly process block" do
      SimpleNewDslMongoid.with_state_scope('unknown_scope') do
        SimpleNewDslMongoid.count
      end.should == 3
      SimpleNewDslMongoid.with_state_scope('new') do
        SimpleNewDslMongoid.count
      end.should == 2
    end

  end
end
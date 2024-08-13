require 'spec_helper'

if defined?(Redis::Objects)
  describe 'redis' do

    Dir[File.dirname(__FILE__) + "/../../models/redis/*.rb"].sort.each do |f|
      require File.expand_path(f)
    end

    before(:all) do
      @model = RedisSimple
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

      it "should return the aasm column when new and the aasm field is not nil" do
        model.status = "beta"
        expect(model.aasm.current_state).to eq(:beta)
      end

      it "should allow a nil state" do
        model.status = nil
        expect(model.aasm.current_state).to be_nil
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
  end
end

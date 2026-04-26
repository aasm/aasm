require 'spec_helper'

if defined?(Redis)
  describe 'redis' do

    Dir[File.dirname(__FILE__) + "/../../models/redis/*.rb"].sort.each do |f|
      require File.expand_path(f)
    end

    before(:all) do
      @model = RedisMultiple
    end

    describe "instance methods" do
      let(:model) {@model.new}

      it "should respond to aasm persistence methods" do
        expect(model).to respond_to(:aasm_read_state)
        expect(model).to respond_to(:aasm_write_state)
        expect(model).to respond_to(:aasm_write_state_without_persistence)
      end

      it "should return the initial state when new and the aasm field is nil" do
        expect(model.aasm(:left).current_state).to eq(:alpha)
      end

      it "should save the initial state" do
        expect(model.status).to eq("alpha")
      end

      it "should return the aasm column the aasm field is not nil" do
        model.status = "beta"
        expect(model.aasm(:left).current_state).to eq(:beta)
      end

      it "should allow a nil state" do
        model.status = nil
        expect(model.aasm(:left).current_state).to be_nil
      end
    end

    describe 'subclasses' do
      it "should have the same states as its parent class" do
        expect(Class.new(@model).aasm(:left).states).to eq(@model.aasm(:left).states)
      end

      it "should have the same events as its parent class" do
        expect(Class.new(@model).aasm(:left).events).to eq(@model.aasm(:left).events)
      end

      it "should have the same column as its parent even for the new dsl" do
        expect(@model.aasm(:left).attribute_name).to eq(:status)
        expect(Class.new(@model).aasm(:left).attribute_name).to eq(:status)
      end
    end

    describe "complex example" do
      it "works" do
        record = RedisComplexExample.new

        expect(record.aasm(:left).current_state).to eql :one
        expect(record.aasm(:right).current_state).to eql :alpha

        expect_aasm_states record, :one, :alpha

        record.increment!
        expect_aasm_states record, :two, :alpha

        record.level_up!
        expect_aasm_states record, :two, :beta

        record.increment!
        expect { record.increment! }.to raise_error(AASM::InvalidTransition)
        expect_aasm_states record, :three, :beta

        record.level_up!
        expect_aasm_states record, :three, :gamma
      end

      def expect_aasm_states(record, left_state, right_state)
        expect(record.aasm(:left).current_state).to eql left_state.to_sym
        expect(record.left.value.to_s).to eql left_state.to_s
        expect(record.aasm(:right).current_state).to eql right_state.to_sym
        expect(record.right.value.to_s).to eql right_state.to_s
      end
    end
  end
end

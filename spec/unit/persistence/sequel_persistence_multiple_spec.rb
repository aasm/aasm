require 'spec_helper'

if defined?(Sequel)
  describe 'sequel' do

    Dir[File.dirname(__FILE__) + "/../../models/sequel/*.rb"].sort.each do |f|
      require File.expand_path(f)
    end

    before(:all) do
      @model = Sequel::Multiple
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
        model.save
        expect(model.status).to eq("alpha")
      end

      it "should return the aasm column when new and the aasm field is not nil" do
        model.status = "beta"
        expect(model.aasm(:left).current_state).to eq(:beta)
      end

      it "should return the aasm column when not new and the aasm_column is not nil" do
        allow(model).to receive(:new?).and_return(false)
        model.status = "gamma"
        expect(model.aasm(:left).current_state).to eq(:gamma)
      end

      it "should allow a nil state" do
        allow(model).to receive(:new?).and_return(false)
        model.status = nil
        expect(model.aasm(:left).current_state).to be_nil
      end

      it "should not change the state if state is not loaded" do
        model.release
        model.save
        model.class.select(:id).first.save
        model.reload
        expect(model.aasm(:left).current_state).to eq(:beta)
      end

      it "should call aasm_ensure_initial_state on validation before create" do
        expect(model).to receive(:aasm_ensure_initial_state).and_return(true)
        model.valid?
      end

      it "should call aasm_ensure_initial_state before create, even if skipping validations" do
        expect(model).to receive(:aasm_ensure_initial_state).and_return(true)
        model.save(:validate => false)
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

    describe 'initial states' do
      it 'should support conditions' do
        @model.aasm(:left) do
          initial_state lambda{ |m| m.default }
        end

        expect(@model.new(:default => :beta).aasm(:left).current_state).to eq(:beta)
        expect(@model.new(:default => :gamma).aasm(:left).current_state).to eq(:gamma)
      end
    end

    describe "complex example" do
      it "works" do
        record = Sequel::ComplexExample.new
        expect(record.aasm(:left).current_state).to eql :one
        expect(record.left).to be_nil
        expect(record.aasm(:right).current_state).to eql :alpha
        expect(record.right).to be_nil

        record.save
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

  end
end

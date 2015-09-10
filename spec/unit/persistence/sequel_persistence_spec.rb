describe 'sequel' do
  begin
    require 'sequel'
    require 'logger'
    require 'spec_helper'

    Dir[File.dirname(__FILE__) + "/../../models/sequel/*.rb"].sort.each do |f|
      require File.expand_path(f)
    end

    before(:all) do
      @model = SequelSimple
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

      it "should save the initial state" do
        model.save
        expect(model.status).to eq("alpha")
      end

      it "should return the aasm column when new and the aasm field is not nil" do
        model.status = "beta"
        expect(model.aasm.current_state).to eq(:beta)
      end

      it "should return the aasm column when not new and the aasm_column is not nil" do
        allow(model).to receive(:new?).and_return(false)
        model.status = "gamma"
        expect(model.aasm.current_state).to eq(:gamma)
      end

      it "should allow a nil state" do
        allow(model).to receive(:new?).and_return(false)
        model.status = nil
        expect(model.aasm.current_state).to be_nil
      end

      it "should not change the state if state is not loaded" do
        model.release
        model.save
        model.class.select(:id).first.save
        model.reload
        expect(model.aasm.current_state).to eq(:beta)
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

    describe 'initial states' do
      it 'should support conditions' do
        @model.aasm do
          initial_state lambda{ |m| m.default }
        end

        expect(@model.new(:default => :beta).aasm.current_state).to eq(:beta)
        expect(@model.new(:default => :gamma).aasm.current_state).to eq(:gamma)
      end
    end

  rescue LoadError
    puts "------------------------------------------------------------------------"
    puts "Not running Sequel specs because sequel gem is not installed!!!"
    puts "------------------------------------------------------------------------"
  end
end

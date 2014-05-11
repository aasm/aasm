
describe 'sequel' do
  begin
    require 'sequel'
    require 'logger'
    require 'spec_helper'

    before(:all) do
      db = Sequel.sqlite
      # if you want to see the statements while running the spec enable the following line
      # db.loggers << Logger.new($stderr)
      db.create_table(:models) do
        primary_key :id
        String :status
      end

      @model = Class.new(Sequel::Model(db)) do
        set_dataset(:models)
        attr_accessor :default
        include AASM
        aasm :column => :status
        aasm do
          state :alpha, :initial => true
          state :beta
          state :gamma
          event :release do
            transitions :from => [:alpha, :beta, :gamma], :to => :beta
          end
        end
      end
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
        expect(@model.aasm_column).to eq(:status)
        expect(Class.new(@model).aasm_column).to eq(:status)
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
    puts "Not running Sequel specs because sequel gem is not installed!!!"
  end
end

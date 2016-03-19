
describe 'redis' do
  begin
    require 'redis-objects'
    require 'logger'
    require 'spec_helper'

    before(:all) do
      Redis.current = Redis.new(host: '127.0.0.1', port: 6379)

      @model = Class.new do
        attr_accessor :default

        include Redis::Objects
        include AASM

        value :status

        def id
          1
        end

        aasm column: :status
        aasm do
          state :alpha, initial: true
          state :beta
          state :gamma
          event :release do
            transitions from: [:alpha, :beta, :gamma], to: :beta
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

  rescue LoadError
    puts "Not running Redis specs because sequel gem is not installed!!!"
  end
end

require 'spec_helper'

describe 'adding an event' do
  let(:event) do
    AASM::Event.new(:close_order, {:success => :success_callback}) do
      before :before_callback
      after :after_callback
      transitions :to => :closed, :from => [:open, :received]
    end
  end

  it 'should set the name' do
    expect(event.name).to eq(:close_order)
  end

  it 'should set the success callback' do
    expect(event.options[:success]).to eq(:success_callback)
  end

  it 'should set the after callback' do
    expect(event.options[:after]).to eq([:after_callback])
  end

  it 'should set the before callback' do
    expect(event.options[:before]).to eq([:before_callback])
  end

  it 'should create transitions' do
    transitions = event.transitions
    expect(transitions[0].from).to eq(:open)
    expect(transitions[0].to).to eq(:closed)
    expect(transitions[1].from).to eq(:received)
    expect(transitions[1].to).to eq(:closed)
  end
end

describe 'transition inspection' do
  let(:event) do
    AASM::Event.new(:run) do
      transitions :to => :running, :from => :sleeping
    end
  end

  it 'should support inspecting transitions from other states' do
    expect(event.transitions_from_state(:sleeping).map(&:to)).to eq([:running])
    expect(event.transitions_from_state?(:sleeping)).to be_true

    expect(event.transitions_from_state(:cleaning).map(&:to)).to eq([])
    expect(event.transitions_from_state?(:cleaning)).to be_false
  end

  it 'should support inspecting transitions to other states' do
    expect(event.transitions_to_state(:running).map(&:from)).to eq([:sleeping])
    expect(event.transitions_to_state?(:running)).to be_true

    expect(event.transitions_to_state(:cleaning).map(&:to)).to eq([])
    expect(event.transitions_to_state?(:cleaning)).to be_false
  end
end

describe 'transition inspection without from' do
  let(:event) do
    AASM::Event.new(:run) do
      transitions :to => :running
    end
  end

  it 'should support inspecting transitions from other states' do
    expect(event.transitions_from_state(:sleeping).map(&:to)).to eq([:running])
    expect(event.transitions_from_state?(:sleeping)).to be_true

    expect(event.transitions_from_state(:cleaning).map(&:to)).to eq([:running])
    expect(event.transitions_from_state?(:cleaning)).to be_true
  end

end

describe 'firing an event' do
  it 'should return nil if the transitions are empty' do
    obj = double('object', :aasm => double('aasm', :current_state => 'open'))

    event = AASM::Event.new(:event)
    expect(event.fire(obj)).to be_nil
  end

  it 'should return the state of the first matching transition it finds' do
    event = AASM::Event.new(:event) do
      transitions :to => :closed, :from => [:open, :received]
    end

    obj = double('object', :aasm => double('aasm', :current_state => :open))

    expect(event.fire(obj)).to eq(:closed)
  end

  it 'should call the guard with the params passed in' do
    event = AASM::Event.new(:event) do
      transitions :to => :closed, :from => [:open, :received], :guard => :guard_fn
    end

    obj = double('object', :aasm => double('aasm', :current_state => :open))
    expect(obj).to receive(:guard_fn).with('arg1', 'arg2').and_return(true)

    expect(event.fire(obj, nil, 'arg1', 'arg2')).to eq(:closed)
  end

end

describe 'should fire callbacks' do
  describe 'success' do
    it "if it's a symbol" do
      ThisNameBetterNotBeInUse.instance_eval {
        aasm do
          event :with_symbol, :success => :symbol_success_callback do
            transitions :to => :symbol, :from => [:initial]
          end
        end
      }

      model = ThisNameBetterNotBeInUse.new
      expect(model).to receive(:symbol_success_callback)
      model.with_symbol!
    end

    it "if it's a string" do
      ThisNameBetterNotBeInUse.instance_eval {
        aasm do
          event :with_string, :success => 'string_success_callback' do
            transitions :to => :string, :from => [:initial]
          end
        end
      }

      model = ThisNameBetterNotBeInUse.new
      expect(model).to receive(:string_success_callback)
      model.with_string!
    end

    it "if passed an array of strings and/or symbols" do
      ThisNameBetterNotBeInUse.instance_eval {
        aasm do
          event :with_array, :success => [:success_callback1, 'success_callback2'] do
            transitions :to => :array, :from => [:initial]
          end
        end
      }

      model = ThisNameBetterNotBeInUse.new
      expect(model).to receive(:success_callback1)
      expect(model).to receive(:success_callback2)
      model.with_array!
    end

    it "if passed an array of strings and/or symbols and/or procs" do
      ThisNameBetterNotBeInUse.instance_eval {
        aasm do
          event :with_array_including_procs, :success => [:success_callback1, 'success_callback2', lambda { proc_success_callback }] do
            transitions :to => :array, :from => [:initial]
          end
        end
      }

      model = ThisNameBetterNotBeInUse.new
      expect(model).to receive(:success_callback1)
      expect(model).to receive(:success_callback2)
      expect(model).to receive(:proc_success_callback)
      model.with_array_including_procs!
    end

    it "if it's a proc" do
      ThisNameBetterNotBeInUse.instance_eval {
        aasm do
          event :with_proc, :success => lambda { proc_success_callback } do
            transitions :to => :proc, :from => [:initial]
          end
        end
      }

      model = ThisNameBetterNotBeInUse.new
      expect(model).to receive(:proc_success_callback)
      model.with_proc!
    end
  end

  describe 'after' do
    it "if they set different ways" do
      ThisNameBetterNotBeInUse.instance_eval do
        aasm do
          event :with_afters, :after => :do_one_thing_after do
            after do
              do_another_thing_after_too
            end
            after do
              do_third_thing_at_last
            end
            transitions :to => :proc, :from => [:initial]
          end
        end
      end

      model = ThisNameBetterNotBeInUse.new
      expect(model).to receive(:do_one_thing_after).once.ordered
      expect(model).to receive(:do_another_thing_after_too).once.ordered
      expect(model).to receive(:do_third_thing_at_last).once.ordered
      model.with_afters!
    end
  end

  describe 'before' do
    it "if it's a proc" do
      ThisNameBetterNotBeInUse.instance_eval do
        aasm do
          event :before_as_proc do
            before do
              do_something_before
            end
            transitions :to => :proc, :from => [:initial]
          end
        end
      end

      model = ThisNameBetterNotBeInUse.new
      expect(model).to receive(:do_something_before).once
      model.before_as_proc!
    end
  end

  it 'in right order' do
    ThisNameBetterNotBeInUse.instance_eval do
      aasm do
        event :in_right_order, :after => :do_something_after do
          before do
            do_something_before
          end
          transitions :to => :proc, :from => [:initial]
        end
      end
    end

    model = ThisNameBetterNotBeInUse.new
    expect(model).to receive(:do_something_before).once.ordered
    expect(model).to receive(:do_something_after).once.ordered
    model.in_right_order!
  end
end

describe 'current event' do
  let(:pe) {ParametrisedEvent.new}

  it 'if no event has been triggered' do
    expect(pe.aasm.current_event).to be_nil
  end

  it 'if a event has been triggered' do
    pe.wakeup
    expect(pe.aasm.current_event).to eql :wakeup
  end

  it 'if no event has been triggered' do
    pe.wakeup!
    expect(pe.aasm.current_event).to eql :wakeup!
  end
end

describe 'parametrised events' do
  let(:pe) {ParametrisedEvent.new}

  it 'should transition to specified next state (sleeping to showering)' do
    pe.wakeup!(:showering)
    expect(pe.aasm.current_state).to eq(:showering)
  end

  it 'should transition to specified next state (sleeping to working)' do
    pe.wakeup!(:working)
    expect(pe.aasm.current_state).to eq(:working)
  end

  it 'should transition to default (first or showering) state' do
    pe.wakeup!
    expect(pe.aasm.current_state).to eq(:showering)
  end

  it 'should transition to default state when on_transition invoked' do
    pe.dress!(nil, 'purple', 'dressy')
    expect(pe.aasm.current_state).to eq(:working)
  end

  it 'should call on_transition method with args' do
    pe.wakeup!(:showering)
    expect(pe).to receive(:wear_clothes).with('blue', 'jeans')
    pe.dress!(:working, 'blue', 'jeans')
  end

  it 'should call on_transition proc' do
    pe.wakeup!(:showering)
    expect(pe).to receive(:wear_clothes).with('purple', 'slacks')
    pe.dress!(:dating, 'purple', 'slacks')
  end

  it 'should call on_transition with an array of methods' do
    pe.wakeup!(:showering)
    expect(pe).to receive(:condition_hair)
    expect(pe).to receive(:fix_hair)
    pe.dress!(:prettying_up)
  end
end

describe 'event firing without persistence' do
  it 'should attempt to persist if aasm_write_state is defined' do
    foo = Foo.new
    def foo.aasm_write_state; end
    expect(foo).to be_open

    expect(foo).to receive(:aasm_write_state_without_persistence)
    foo.close
  end
end

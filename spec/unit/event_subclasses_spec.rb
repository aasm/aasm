require 'spec_helper'

describe 'customized event classes' do
  let(:state_machine) { AASM::StateMachine.new(:name).tap { |sm| CustomAasmBase.new(nil, :name, sm) } }

  it 'should allow custom transition options' do
    opts = {:some_option => '-- some value --'}
    event = CustomEvent.new(:event_name, state_machine, opts)

    expect(event.some_option).to eq('-- some value --')
  end

  it 'should set custom transition options from the dsl' do
    opts = { }
    event = CustomEvent.new(:event_name, state_machine, opts) do
      some_option '-- another value --'
    end

    expect(event.some_option).to eq(['-- another value --'])
  end

  it 'should allow custom transition methods' do
    opts = { }
    event = CustomEvent.new(:event_name, state_machine, opts) do
      custom_event_method!(42)
    end

    expect(event.custom_method_args).to eq(42)
  end
end

describe 'customized transition classes' do
  let(:state_machine) { AASM::StateMachine.new(:name).tap { |sm| CustomAasmBase.new(nil, :name, sm) } }
  let(:event) do
    AASM::Core::Event.new(:event_name, state_machine) do
      transitions :to => :closed, :from => [:open, :received], success: [:transition_success_callback]
    end
  end

  it 'should use a subclass of transition' do
    transitions = event.transitions
    expect(transitions.first).to be_a(CustomTransition)
  end
end

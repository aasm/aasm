require 'spec_helper'

describe 'custom transition sublasses do' do
  let(:state_machine) { AASM::StateMachine.new(:name) }
  let(:event) { AASM::Core::Event.new(:event, state_machine) }

  it 'should allow custom transition options' do
    opts = {:from => 'foo', :to => 'bar', :some_option => '-- some value --'}
    transition = CustomTransition.new(event, opts)

    expect(transition.some_option).to eq('-- some value --')
  end

  it 'should set custom transition options from the dsl' do
    opts = {:from => 'foo', :to => 'bar'}
    transition = CustomTransition.new(event, opts) do
      some_option '-- another value --'
    end

    expect(transition.some_option).to eq(['-- another value --'])
  end

  it 'should allow custom transition methods' do
    opts = {:from => 'foo', :to => 'bar'}
    transition = CustomTransition.new(event, opts) do
      custom_transition_method!(42)
    end

    expect(transition.custom_method_args).to eq(42)
  end
end

require File.join(File.dirname(__FILE__), '..', 'spec_helper')

# TODO These are specs ported from original aasm
describe AASM::SupportingClasses::State do
  before(:each) do
    @name    = :astate
    @options = { :crazy_custom_key => 'key' }
    @record  = mock('record')
  end

  def new_state
    @state = AASM::SupportingClasses::State.new(@name, @options)
  end

  it 'should set the name' do
    new_state

    @state.name.should == :astate
  end
  
  it 'should set the options and expose them as options' do
    new_state
    
    @state.options.should == @options
  end

  it '#entering should not run_transition_action if :enter option is not passed' do
    new_state
    @record.should_not_receive(:run_transition_action)

    @state.entering(@record)
  end

  it '#entered should not run_transition_action if :after option is not passed' do
    new_state
    @record.should_not_receive(:run_transition_action)

    @state.entered(@record)
  end
  
  it '#exited should not run_transition_action if :exit option is not passed' do
    new_state
    @record.should_not_receive(:run_transition_action)

    @state.exited(@record)
  end

  it '#entering should run_transition_action when :enter option is passed' do
    @options[:enter] = true
    new_state
    @record.should_receive(:run_transition_action).with(true)

    @state.entering(@record)
  end

  it '#entered should run_transition_action for each option when :after option is passed' do
    @options[:after] = ['a', 'b']
    new_state
    @record.should_receive(:run_transition_action).once.with('a')
    @record.should_receive(:run_transition_action).once.with('b')

    @state.entered(@record)
  end

  it '#exited should run_transition_action when :exit option is passed' do
    @options[:exit] = true
    new_state
    @record.should_receive(:run_transition_action).with(true)

    @state.exited(@record)
  end
end

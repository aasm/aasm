require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class Foo2
  include AASM
  aasm_initial_state :open
  aasm_state :open,
    :before_enter => :before_enter_open,
    :before_exit => :before_exit_open,
    :after_enter => :after_enter_open,
    :after_exit => :after_exit_open
  aasm_state :closed,
    :before_enter => :before_enter_closed,
    :before_exit => :before_exit_closed,
    :after_enter => :after_enter_closed,
    :after_exit => :after_exit_closed

  aasm_event :close, :before => :before, :after => :after do
    transitions :to => :closed, :from => [:open]
  end

  aasm_event :open, :before => :before, :after => :after do
    transitions :to => :open, :from => :closed
  end

  def before_enter_open
  end
  def before_exit_open
  end
  def after_enter_open
  end
  def after_exit_open
  end

  def before_enter_closed
  end
  def before_exit_closed
  end
  def after_enter_closed
  end
  def after_exit_closed
  end

  def before
  end
  def after
  end
end

describe Foo2, '- new callbacks' do
  before(:each) do
    @foo = Foo2.new
  end

  it "should get close callbacks" do
    @foo.should_receive(:before).once.ordered
    @foo.should_receive(:before_exit_open).once.ordered                   # these should be before the state changes
    @foo.should_receive(:before_enter_closed).once.ordered
    @foo.should_receive(:aasm_write_state).once.ordered.and_return(true)  # this is when the state changes
    @foo.should_receive(:after_exit_open).once.ordered                    # these should be after the state changes
    @foo.should_receive(:after_enter_closed).once.ordered
    @foo.should_receive(:after).once.ordered

    @foo.close!
  end

  it "should get open callbacks" do
    @foo.close!
    
    @foo.should_receive(:before).once.ordered                                                                       
    @foo.should_receive(:before_exit_closed).once.ordered                # these should be before the state changes
    @foo.should_receive(:before_enter_open).once.ordered                                                            
    @foo.should_receive(:aasm_write_state).once.ordered.and_return(true) # this is when the state changes
    @foo.should_receive(:after_exit_closed).once.ordered                 # these should be after the state changes
    @foo.should_receive(:after_enter_open).once.ordered
    @foo.should_receive(:after).once.ordered

    @foo.open!
  end
end

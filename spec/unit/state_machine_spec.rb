require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe "state machines" do

  def number_of_objects(clazz)
    ObjectSpace.each_object(clazz) {}
  end
  
  def machines
    AASM::StateMachine.instance_variable_get("@machines")
  end

  it "should be created without memory leak" do
    machines_count = machines.size
    state_count = number_of_objects(AASM::SupportingClasses::State)
    event_count = number_of_objects(AASM::SupportingClasses::Event)
    transition_count = number_of_objects(AASM::SupportingClasses::StateTransition)

    load File.expand_path(File.dirname(__FILE__) + '/../models/not_auto_loaded/process.rb')
    machines.size.should == machines_count + 1                                                  # + Process
    number_of_objects(Models::Process).should == 0
    number_of_objects(AASM::SupportingClasses::State).should == state_count + 3                 # + Process
    number_of_objects(AASM::SupportingClasses::Event).should == event_count + 2                 # + Process
    number_of_objects(AASM::SupportingClasses::StateTransition).should == transition_count + 2  # + Process

    Models.send(:remove_const, "Process") if Models.const_defined?("Process")
    load File.expand_path(File.dirname(__FILE__) + '/../models/not_auto_loaded/process.rb')
    machines.size.should == machines_count + 1                                                  # + Process
    number_of_objects(AASM::SupportingClasses::State).should == state_count + 3                 # + Process
    number_of_objects(AASM::SupportingClasses::Event).should == event_count + 2                 # + Process
    number_of_objects(AASM::SupportingClasses::StateTransition).should == transition_count + 2  # + Process
  end

end

# require 'spec_helper'

# describe "state machines" do

#   def number_of_objects(klass)
#     ObjectSpace.each_object(klass) {}
#   end

#   def machines
#     AASM::StateMachine.instance_variable_get("@machines")
#   end

#   it "should be created without memory leak" do
#     machines_count = machines.size
#     state_count = number_of_objects(AASM::State)
#     event_count = number_of_objects(AASM::Event)
#     puts "event_count = #{event_count}"
#     transition_count = number_of_objects(AASM::Transition)

#     load File.expand_path(File.dirname(__FILE__) + '/../models/not_auto_loaded/process.rb')
#     machines.size.should == machines_count + 1                                                  # + Process
#     number_of_objects(Models::Process).should == 0
#     number_of_objects(AASM::State).should == state_count + 3                 # + Process
#     puts "event_count = #{number_of_objects(AASM::Event)}"
#     number_of_objects(AASM::Event).should == event_count + 2                 # + Process
#     number_of_objects(AASM::Transition).should == transition_count + 2  # + Process

#     Models.send(:remove_const, "Process") if Models.const_defined?("Process")
#     load File.expand_path(File.dirname(__FILE__) + '/../models/not_auto_loaded/process.rb')
#     machines.size.should == machines_count + 1                                                  # + Process
#     number_of_objects(AASM::State).should == state_count + 3                 # + Process
#     # ObjectSpace.each_object(AASM::Event) {|o| puts o.inspect}
#     puts "event_count = #{number_of_objects(AASM::Event)}"
#     number_of_objects(AASM::Event).should == event_count + 2                 # + Process
#     number_of_objects(AASM::Transition).should == transition_count + 2  # + Process
#   end

# end

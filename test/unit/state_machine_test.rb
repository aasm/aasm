require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class StateMachineTest < Test::Unit::TestCase
  
  context "state machines" do
    
    should "be created without memory leak" do
      assert_equal 1, AASM::StateMachine.instance_variable_get("@machines").size  # AuthMachine      
      assert_number_of_objects AASM::SupportingClasses::State, 5                  # AuthMachine
      assert_number_of_objects AASM::SupportingClasses::Event, 10                 # AuthMachine
      assert_number_of_objects AASM::SupportingClasses::StateTransition, 18       # AuthMachine
      
      load File.expand_path(File.dirname(__FILE__) + '/../models/process.rb')
      assert_equal 2, AASM::StateMachine.instance_variable_get("@machines").size  # AuthMachine + Process
      assert_number_of_objects Models::Process, 0
      assert_number_of_objects AASM::SupportingClasses::State, 8                  # AuthMachine + Process
      assert_number_of_objects AASM::SupportingClasses::Event, 12                 # AuthMachine + Process
      assert_number_of_objects AASM::SupportingClasses::StateTransition, 20       # AuthMachine + Process
      
      Models.send(:remove_const, "Process") if Models.const_defined?("Process")
      load File.expand_path(File.dirname(__FILE__) + '/../models/process.rb')
      assert_equal 2, AASM::StateMachine.instance_variable_get("@machines").size  # AuthMachine + Process
      assert_number_of_objects AASM::SupportingClasses::State, 8                  # AuthMachine + Process
      assert_number_of_objects AASM::SupportingClasses::Event, 12                 # AuthMachine + Process
      assert_number_of_objects AASM::SupportingClasses::StateTransition, 20       # AuthMachine + Process
    end
    
  end
  
  private
  
    def assert_number_of_objects(clazz, num)
      count = ObjectSpace.each_object(clazz) {}
      assert_equal num, count, "#{num} expected, but we had #{count} #{clazz}"
    end
  
end

require 'spec_helper'
if defined?(ActiveRecord)
  require 'models/active_record/person'

  load_schema
  describe 'Abstract subclassing' do

    it 'should have the parent states' do
      Person.aasm.states.each do |state|
        expect(Base.aasm.states).to include(state)
      end
      expect(Person.aasm.states).to eq(Base.aasm.states)
    end

    it 'should have the same events as its parent' do
      expect(Base.aasm.events).to eq(Person.aasm.events)
    end

    it 'should not break aasm methods when super class is abstract_class' do
      person = Person.new
      person.status = 'active'
      person.deactivate!
      expect(person.aasm.current_state).to eq(:inactive)
    end

  end
end

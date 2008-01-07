require File.join(File.dirname(__FILE__), '..', 'lib', 'state')
require File.join(File.dirname(__FILE__), '..', 'lib', 'state_factory')

describe AASM::SupportingClasses::StateFactory, '- when creating a new State' do
  before(:each) do
    @state = :scott
    @opts  = {:a => 'b'}

    AASM::SupportingClasses::StateFactory.create(@state, @opts)
  end

  it 'should create a new State if it has not been created yet' do
    AASM::SupportingClasses::State.should_receive(:new).with(:foo, :bar => 'baz')

    AASM::SupportingClasses::StateFactory.create(:foo, :bar => 'baz')
  end

  it 'should not create a new State if it has already been created' do
    AASM::SupportingClasses::State.should_not_receive(:new).with(@state, @opts)

    AASM::SupportingClasses::StateFactory.create(@state, @opts)
  end
end

describe AASM::SupportingClasses::StateFactory, '- when retrieving a State via []' do
  before(:each) do
    @state_name = :scottb
    @opts  = {:a => 'b'}

    AASM::SupportingClasses::StateFactory.create(@state_name, @opts)
  end

  it 'should return nil if the State was never created' do
    AASM::SupportingClasses::StateFactory[:foo].should be_nil
  end

  it 'should return the State' do
    AASM::SupportingClasses::StateFactory[@state_name].should_not be_nil
  end
end

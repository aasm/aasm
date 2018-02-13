require 'spec_helper'

describe 'transitions' do

  it 'should raise an exception when whiny' do
    process = ProcessWithNewDsl.new
    expect { process.stop! }.to raise_error do |err|
      expect(err.class).to eql(AASM::InvalidTransition)
      expect(err.message).to eql("Event 'stop' cannot transition from 'sleeping'.")
      expect(err.object).to eql(process)
      expect(err.event_name).to eql(:stop)
    end
    expect(process).to be_sleeping
  end

  it 'should not raise an exception when not whiny' do
    silencer = Silencer.new
    expect(silencer.smile!).to be_falsey
    expect(silencer).to be_silent
  end

  it 'should not raise an exception when superclass not whiny' do
    sub = SubClassing.new
    expect(sub.smile!).to be_falsey
    expect(sub).to be_silent
  end

  it 'should not raise an exception when from is nil even if whiny' do
    silencer = Silencer.new
    expect(silencer.smile_any!).to be_truthy
    expect(silencer).to be_smiling
  end

  it 'should call the block on success' do
    silencer = Silencer.new
    success = false
    expect {
      silencer.smile_any! do
        success = true
      end
    }.to change { success }.to(true)
  end

  it 'should not call the block on failure' do
    silencer = Silencer.new
    success = false
    expect {
      silencer.smile! do
        success = true
      end
    }.not_to change { success }
  end

end

describe AASM::Core::Transition do
  let(:state_machine) { AASM::StateMachine.new(:name) }
  let(:event) { AASM::Core::Event.new(:event, state_machine) }

  it 'should set from, to, and opts attr readers' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Core::Transition.new(event, opts)

    expect(st.from).to eq(opts[:from])
    expect(st.to).to eq(opts[:to])
    expect(st.opts).to eq(opts)
  end

  it 'should set on_transition with deprecation warning' do
    opts = {:from => 'foo', :to => 'bar'}
    st = AASM::Core::Transition.allocate
    expect(st).to receive(:warn).with('[DEPRECATION] :on_transition is deprecated, use :after instead')

    st.send :initialize, event, opts do
      guard :gg
      on_transition :after_callback
    end

    expect(st.opts[:after]).to eql [:after_callback]
  end

  it 'should set after, guard and success from dsl' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Core::Transition.new(event, opts) do
      guard :gg
      after :after_callback
      success :after_persist
    end

    expect(st.opts[:guard]).to eql ['g', :gg]
    expect(st.opts[:after]).to eql [:after_callback] # TODO fix this bad code coupling
    expect(st.opts[:success]).to eql [:after_persist] # TODO fix this bad code coupling
  end

  it 'should pass equality check if from and to are the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    allow(obj).to receive(:from).and_return(opts[:from])
    allow(obj).to receive(:to).and_return(opts[:to])

    expect(st).to eq(obj)
  end

  it 'should fail equality check if from are not the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    allow(obj).to receive(:from).and_return('blah')
    allow(obj).to receive(:to).and_return(opts[:to])

    expect(st).not_to eq(obj)
  end

  it 'should fail equality check if to are not the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    allow(obj).to receive(:from).and_return(opts[:from])
    allow(obj).to receive(:to).and_return('blah')

    expect(st).not_to eq(obj)
  end
end

describe AASM::Core::Transition, '- when performing guard checks' do
  let(:state_machine) { AASM::StateMachine.new(:name) }
  let(:event) { AASM::Core::Event.new(:event, state_machine) }

  it 'should return true of there is no guard' do
    opts = {:from => 'foo', :to => 'bar'}
    st = AASM::Core::Transition.new(event, opts)

    expect(st.allowed?(nil)).to be_truthy
  end

  it 'should call the method on the object if guard is a symbol' do
    opts = {:from => 'foo', :to => 'bar', :guard => :test}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    expect(obj).to receive(:test)

    expect(st.allowed?(obj)).to be false
  end

  it 'should add the name of the failed method calls to the failures instance var' do
    opts = {:from => 'foo', :to => 'bar', :guard => :test}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    expect(obj).to receive(:test)

    st.allowed?(obj)
    expect(st.failures).to eq [:test]
  end

  it 'should call the method on the object if unless is a symbol' do
    opts = {:from => 'foo', :to => 'bar', :unless => :test}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    expect(obj).to receive(:test)

    expect(st.allowed?(obj)).to be true
  end

  it 'should call the method on the object if guard is a string' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'test'}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    expect(obj).to receive(:test)

    expect(st.allowed?(obj)).to be false
  end

  it 'should call the method on the object if unless is a string' do
    opts = {:from => 'foo', :to => 'bar', :unless => 'test'}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    expect(obj).to receive(:test)

    expect(st.allowed?(obj)).to be true
  end

  it 'should call the proc passing the object if the guard is a proc' do
    opts = {:from => 'foo', :to => 'bar', :guard => Proc.new { test }}
    st = AASM::Core::Transition.new(event, opts)

    obj = double('object')
    expect(obj).to receive(:test)

    expect(st.allowed?(obj)).to be false
  end
end

describe AASM::Core::Transition, '- when executing the transition with a Proc' do
  let(:state_machine) { AASM::StateMachine.new(:name) }
  let(:event) { AASM::Core::Event.new(:event, state_machine) }

  it 'should call a Proc on the object with args' do
    opts = {:from => 'foo', :to => 'bar', :after => Proc.new {|a| test(a) }}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    expect(obj).to receive(:test).with(args)

    st.execute(obj, args)
  end

  it 'should call a Proc on the object without args' do
    # in order to test that the Proc has been called, we make sure
    # that after running the :after callback the prc_object is set
    prc_object = nil
    prc = Proc.new { prc_object = self }

    opts = {:from => 'foo', :to => 'bar', :after => prc }
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    st.execute(obj, args)
    expect(prc_object).to eql obj
  end
end

describe AASM::Core::Transition, '- when executing the transition with an :after method call' do
  let(:state_machine) { AASM::StateMachine.new(:name) }
  let(:event) { AASM::Core::Event.new(:event, state_machine) }

  it 'should accept a String for the method name' do
    opts = {:from => 'foo', :to => 'bar', :after => 'test'}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    expect(obj).to receive(:test)

    st.execute(obj, args)
  end

  it 'should accept a Symbol for the method name' do
    opts = {:from => 'foo', :to => 'bar', :after => :test}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    expect(obj).to receive(:test)

    st.execute(obj, args)
  end

  it 'should pass args if the target method accepts them' do
    opts = {:from => 'foo', :to => 'bar', :after => :test}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    def obj.test(args)
      "arg1: #{args[:arg1]} arg2: #{args[:arg2]}"
    end

    return_value = st.execute(obj, args)

    expect(return_value).to eq('arg1: 1 arg2: 2')
  end

  it 'should NOT pass args if the target method does NOT accept them' do
    opts = {:from => 'foo', :to => 'bar', :after => :test}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    def obj.test
      'success'
    end

    return_value = st.execute(obj, args)

    expect(return_value).to eq('success')
  end

  it 'should allow accessing the from_state and the to_state' do
    opts = {:from => 'foo', :to => 'bar', :after => :test}
    transition = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => AASM::InstanceBase.new('object'))

    def obj.test(args)
      "from: #{aasm.from_state} to: #{aasm.to_state}"
    end

    return_value = transition.execute(obj, args)

    expect(return_value).to eq('from: foo to: bar')
  end

end

describe AASM::Core::Transition, '- when executing the transition with a Class' do
  let(:state_machine) { AASM::StateMachine.new(:name) }
  let(:event) { AASM::Core::Event.new(:event, state_machine) }

  class AfterTransitionClass
    def initialize(record)
      @record = record
    end

    def call
      "from: #{@record.aasm.from_state} to: #{@record.aasm.to_state}"
    end
  end

  class AfterTransitionClassWithArgs
    def initialize(record, args)
      @record = record
      @args = args
    end

    def call
      "arg1: #{@args[:arg1]}, arg2: #{@args[:arg2]}"
    end
  end

  class AfterTransitionClassWithoutArgs
    def call
      'success'
    end
  end

  it 'passes the record to the initialize method on the class to give access to the from_state and to_state' do
    opts = {:from => 'foo', :to => 'bar', :after => AfterTransitionClass}
    transition = AASM::Core::Transition.new(event, opts)
    obj = double('object', :aasm => AASM::InstanceBase.new('object'))

    return_value = transition.execute(obj)

    expect(return_value).to eq('from: foo to: bar')
  end

  it 'should pass args to the initialize method on the class if it accepts them' do
    opts = {:from => 'foo', :to => 'bar', :after => AfterTransitionClassWithArgs}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    return_value = st.execute(obj, args)

    expect(return_value).to eq('arg1: 1, arg2: 2')
  end

  it 'should NOT pass args if the call method of the class if it does NOT accept them' do
    opts = {:from => 'foo', :to => 'bar', :after => AfterTransitionClassWithoutArgs}
    st = AASM::Core::Transition.new(event, opts)
    obj = double('object', :aasm => 'aasm')

    return_value = st.execute(obj)

    expect(return_value).to eq('success')
  end
end

describe AASM::Core::Transition, '- when invoking the transition :success method call' do
  let(:state_machine) { AASM::StateMachine.new(:name) }
  let(:event) { AASM::Core::Event.new(:event, state_machine) }

  it 'should accept a String for the method name' do
    opts = {:from => 'foo', :to => 'bar', :success => 'test'}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    expect(obj).to receive(:test)

    st.invoke_success_callbacks(obj, args)
  end

  it 'should accept a Symbol for the method name' do
    opts = {:from => 'foo', :to => 'bar', :success => :test}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    expect(obj).to receive(:test)

    st.invoke_success_callbacks(obj, args)
  end

  it 'should accept a Array for the method name' do
    opts = {:from => 'foo', :to => 'bar', :success => [:test1, :test2]}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    expect(obj).to receive(:test1)
    expect(obj).to receive(:test2)

    st.invoke_success_callbacks(obj, args)
  end

  it 'should pass args if the target method accepts them' do
    opts = {:from => 'foo', :to => 'bar', :success => :test}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    def obj.test(args)
      "arg1: #{args[:arg1]} arg2: #{args[:arg2]}"
    end

    return_value = st.invoke_success_callbacks(obj, args)

    expect(return_value).to eq('arg1: 1 arg2: 2')
  end

  it 'should NOT pass args if the target method does NOT accept them' do
    opts = {:from => 'foo', :to => 'bar', :success => :test}
    st = AASM::Core::Transition.new(event, opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = double('object', :aasm => 'aasm')

    def obj.test
      'success'
    end

    return_value = st.invoke_success_callbacks(obj, args)

    expect(return_value).to eq('success')
  end
end

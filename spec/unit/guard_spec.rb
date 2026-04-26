require 'spec_helper'

describe "per-transition guards" do
  let(:guardian) { Guardian.new }

  it "allows the transition if the guard succeeds" do
    expect { guardian.use_one_guard_that_succeeds! }.to_not raise_error
    expect(guardian).to be_beta
  end

  it "stops the transition if the guard fails" do
    expect { guardian.use_one_guard_that_fails! }.to raise_error(AASM::InvalidTransition)
    expect(guardian).to be_alpha
  end

  it "allows the transition if all guards succeeds" do
    expect { guardian.use_guards_that_succeed! }.to_not raise_error
    expect(guardian).to be_beta
  end

  it "stops the transition if the first guard fails" do
    expect { guardian.use_guards_where_the_first_fails! }.to raise_error(AASM::InvalidTransition)
    expect(guardian).to be_alpha
  end

  it "stops the transition if the second guard fails" do
    expect { guardian.use_guards_where_the_second_fails! }.to raise_error(AASM::InvalidTransition)
    expect(guardian).to be_alpha
  end

  describe "with params" do
    it "using a Proc" do
      expect(guardian).to receive(:inner_guard).with({:flag => true}).and_return(true)
      guardian.use_proc_guard_with_params(:flag => true)
    end

    it "using a lambda" do
      expect(guardian).to receive(:inner_guard).with({:flag => true}).and_return(true)
      guardian.use_lambda_guard_with_params(:flag => true)
    end
  end
end

describe "event guards" do
  let(:guardian) { Guardian.new }

  it "allows the transition if the event guards succeed" do
    expect { guardian.use_event_guards_that_succeed! }.to_not raise_error
    expect(guardian).to be_beta
  end

  it "allows the transition if the event and transition guards succeed" do
    expect { guardian.use_event_and_transition_guards_that_succeed! }.to_not raise_error
    expect(guardian).to be_beta
  end

  it "stops the transition if the first event guard fails" do
    expect { guardian.use_event_guards_where_the_first_fails! }.to raise_error(AASM::InvalidTransition)
    expect(guardian).to be_alpha
  end

  it "stops the transition if the second event guard fails" do
    expect { guardian.use_event_guards_where_the_second_fails! }.to raise_error(AASM::InvalidTransition)
    expect(guardian).to be_alpha
  end

  it "stops the transition if the transition guard fails" do
    expect { guardian.use_event_and_transition_guards_where_third_fails! }.to raise_error(AASM::InvalidTransition)
    expect(guardian).to be_alpha
  end

end

if defined?(ActiveRecord)

  Dir[File.dirname(__FILE__) + "/../models/active_record/*.rb"].sort.each do |f|
    require File.expand_path(f)
  end

  load_schema

  describe "ActiveRecord per-transition guards" do
    let(:example) { ComplexActiveRecordExample.new }

    it "should be able to increment" do
      expect(example.may_increment?).to be true
    end
  end
end

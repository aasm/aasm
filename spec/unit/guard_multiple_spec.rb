require 'spec_helper'

describe "per-transition guards" do
  let(:guardian) { GuardianMultiple.new }

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
end

describe "event guards" do
  let(:guardian) { GuardianMultiple.new }

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

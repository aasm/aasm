require 'spec_helper'

describe 'state machine' do
  let(:namespaced) { NamespacedMultipleExample.new }

  it 'starts with an initial state' do
    expect(namespaced.aasm(:status).current_state).to eq(:unapproved)
    expect(namespaced).to respond_to(:unapproved?)
    expect(namespaced).to be_unapproved

    expect(namespaced.aasm(:review_status).current_state).to eq(:unapproved)
    expect(namespaced).to respond_to(:review_unapproved?)
    expect(namespaced).to be_review_unapproved
  end

  it 'allows transitions to other states' do
    expect(namespaced).to respond_to(:approve)
    expect(namespaced).to respond_to(:approve!)
    namespaced.approve!
    expect(namespaced).to respond_to(:approved?)
    expect(namespaced).to be_approved

    expect(namespaced).to respond_to(:approve_review)
    expect(namespaced).to respond_to(:approve_review!)
    namespaced.approve_review!
    expect(namespaced).to respond_to(:review_approved?)
    expect(namespaced).to be_review_approved
  end

  it 'denies transitions to other states' do
    expect {namespaced.unapprove}.to raise_error(AASM::InvalidTransition)
    expect {namespaced.unapprove!}.to raise_error(AASM::InvalidTransition)
    namespaced.approve
    expect {namespaced.approve}.to raise_error(AASM::InvalidTransition)
    expect {namespaced.approve!}.to raise_error(AASM::InvalidTransition)
    namespaced.unapprove

    expect {namespaced.unapprove_review}.to raise_error(AASM::InvalidTransition)
    expect {namespaced.unapprove_review!}.to raise_error(AASM::InvalidTransition)
    namespaced.approve_review
    expect {namespaced.approve_review}.to raise_error(AASM::InvalidTransition)
    expect {namespaced.approve_review!}.to raise_error(AASM::InvalidTransition)
    namespaced.unapprove_review
  end

  it 'defines constants for each state name' do
    expect(NamespacedMultipleExample::STATE_UNAPPROVED).to eq(:unapproved)
    expect(NamespacedMultipleExample::STATE_APPROVED).to eq(:approved)

    expect(NamespacedMultipleExample::STATE_REVIEW_UNAPPROVED).to eq(:unapproved)
    expect(NamespacedMultipleExample::STATE_REVIEW_APPROVED).to eq(:approved)
  end
end

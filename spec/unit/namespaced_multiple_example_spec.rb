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

    expect(namespaced.aasm(:car).current_state).to eq(:unsold)
    expect(namespaced).to respond_to(:car_unsold?)
    expect(namespaced).to be_car_unsold
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

    expect(namespaced).to respond_to(:sell_car)
    expect(namespaced).to respond_to(:sell_car!)
    namespaced.sell_car!
    expect(namespaced).to respond_to(:car_sold?)
    expect(namespaced).to be_car_sold
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

    expect {namespaced.return_car}.to raise_error(AASM::InvalidTransition)
    expect {namespaced.return_car!}.to raise_error(AASM::InvalidTransition)
    namespaced.sell_car
    expect {namespaced.sell_car}.to raise_error(AASM::InvalidTransition)
    expect {namespaced.sell_car!}.to raise_error(AASM::InvalidTransition)
    namespaced.return_car
  end

  it 'defines constants for each state name' do
    expect(NamespacedMultipleExample::STATE_UNAPPROVED).to eq(:unapproved)
    expect(NamespacedMultipleExample::STATE_APPROVED).to eq(:approved)

    expect(NamespacedMultipleExample::STATE_REVIEW_UNAPPROVED).to eq(:unapproved)
    expect(NamespacedMultipleExample::STATE_REVIEW_APPROVED).to eq(:approved)

    expect(NamespacedMultipleExample::STATE_CAR_UNSOLD).to eq(:unsold)
    expect(NamespacedMultipleExample::STATE_CAR_SOLD).to eq(:sold)
  end


end

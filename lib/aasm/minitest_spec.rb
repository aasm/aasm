require 'aasm/minitest'

module Minitest::Expectations
  AASM.infect_an_assertion :assert_transitions_from, :must_transition_from, :do_not_flip
  AASM.infect_an_assertion :refute_transitions_from, :wont_transition_from, :do_not_flip

  AASM.infect_an_assertion :assert_transition_to_allowed, :must_allow_transition_to, :do_not_flip
  AASM.infect_an_assertion :refute_transition_to_allowed, :wont_allow_transition_to, :do_not_flip

  AASM.infect_an_assertion :assert_have_state, :must_have_state, :do_not_flip
  AASM.infect_an_assertion :refute_have_state, :wont_have_state, :do_not_flip

  AASM.infect_an_assertion :assert_event_allowed, :must_allow_event, :do_not_flip
  AASM.infect_an_assertion :refute_event_allowed, :wont_allow_event, :do_not_flip
end

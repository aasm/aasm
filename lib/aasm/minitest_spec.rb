require 'aasm/minitest'

# infect_an_assertion only ever defines the generated must_*/wont_*
# method as an instance method on whatever module it's called on.
# Under Minitest 5.x, calling it on an arbitrary module (e.g. AASM)
# also happened to define the real method on Minitest::Expectation
# (used by e.g. `_(obj).must_foo`) via a second, deprecated code path -
# but that path was removed in Minitest 6.0, so `AASM.infect_an_assertion`
# alone stopped having any effect on `_(obj).must_foo`/`value(obj).must_foo`
# usage, and every must_*/wont_* assertion here raised NoMethodError for
# an instance of Minitest::Expectation.
#
# Call infect_an_assertion on both:
# - AASM, preserving whatever legacy behavior Minitest 5.x's deprecated
#   global mechanism still provides there (e.g. bare `obj.must_foo`,
#   which depends on that mechanism and isn't otherwise restorable here -
#   it was intentionally removed from Minitest 6.0 itself, not something
#   AASM controls).
# - Minitest::Expectation directly, which is what `_(obj).must_foo` /
#   `value(obj).must_foo` / `expect(obj).must_foo` actually dispatch
#   through, and works correctly on both Minitest 5.x and 6.x.
[AASM, Minitest::Expectation].each do |receiver|
  receiver.infect_an_assertion :assert_transitions_from, :must_transition_from, :do_not_flip
  receiver.infect_an_assertion :refute_transitions_from, :wont_transition_from, :do_not_flip

  receiver.infect_an_assertion :assert_transition_to_allowed, :must_allow_transition_to, :do_not_flip
  receiver.infect_an_assertion :refute_transition_to_allowed, :wont_allow_transition_to, :do_not_flip

  receiver.infect_an_assertion :assert_have_state, :must_have_state, :do_not_flip
  receiver.infect_an_assertion :refute_have_state, :wont_have_state, :do_not_flip

  receiver.infect_an_assertion :assert_event_allowed, :must_allow_event, :do_not_flip
  receiver.infect_an_assertion :refute_event_allowed, :wont_allow_event, :do_not_flip
end

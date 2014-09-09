# Planned changes for AASM 4

 * **done**: firing an event does not require `to_state` parameter anymore (closing [issue #11](https://github.com/aasm/aasm/issues/11), [issue #58](https://github.com/aasm/aasm/issues/58) and [issue #80](https://github.com/aasm/aasm/issues/80))
 * **done**: don't allow direct assignment of state attribute (see [issue #53](https://github.com/aasm/aasm/issues/53))
 * remove old callbacks (see [issue #96](https://github.com/aasm/aasm/issues/96))
 * remove old aasm DSL (like `aasm_state`)


# Planned changes for AASM >= 3.9

 * deprecate old aasm DSL (`aasm_state`, etc.)
 * deprecate old callbacks
 * clean-up localization and human methods

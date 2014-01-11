# Planned changes for AASM 4

 * **done**: firing an event does not require `to_state` parameter anymore (closing issues #11, #58, #80)
 * don't allow direct assignment of state attribute (see #53)
 * remove old callbacks (see #96)
 * remove old aasm DSL (like `aasm_state`)


# Planned changes for AASM >= 3.9

 * deprecate old aasm DSL (`aasm_state`, etc.)
 * deprecate old callbacks
 * clean-up localization and human methods

# Planned changes

## later

   * drop support for aasm_column ?

# Currently working on


# Changes so far

## version 4.3

 * add support for multiple state machines per class
   * class- and instance-level `aasm` methods accept a state machine selector
     (aka the state machine _name_)
     * if no selector/name is provided, `:default` will be used
   * duplicate definitions of states and events will issue warnings
   * check all tests
     * _ActiveRecord_
     * _Mongoid_
     * _MongoMapper_
     * _Sequel_
   * what happen's if someone accesses `aasm`, but has defined a
     state machine for `aasm(:my_name)`?
   * documentation
 * drop support for find_in_state, count_in_state, calculate_in_state, with_state_scope

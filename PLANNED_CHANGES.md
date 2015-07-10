# Planned changes

## version 4.3

 * add support for multiple state machines per class
   * persistence
     * _MongoMapper_
     * _Sequel_
   * what happen's if someone accesses `aasm`, but has defined a
     state machine for `aasm(:my_name)`?
   * documentation
   * silence warnings?

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

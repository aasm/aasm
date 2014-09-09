require 'ostruct'

%w(
    version
    errors
    configuration
    base
    dsl_helper
    instance_base
    transition
    event
    state
    localizer
    state_machine
    persistence
    aasm
  ).each { |file| require File.join(File.dirname(__FILE__), 'aasm', file) }

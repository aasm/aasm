require 'ostruct'

%w(
    version
    errors
    configuration
    base
    instance_base
    transition
    event
    state
    localizer
    state_machine
    persistence
    aasm
  ).each { |file| require File.join(File.dirname(__FILE__), 'aasm', file) }

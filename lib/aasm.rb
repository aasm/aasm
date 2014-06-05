require 'ostruct'

%w(
    version
    errors
    base
    instance_base
    transition
    event
    state
    localizer
    methods
    state_machine
    persistence
    aasm
  ).each { |file| require File.join(File.dirname(__FILE__), 'aasm', file) }

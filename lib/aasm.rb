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
    state_machine
    persistence
    aasm
  ).each { |file| require File.join(File.dirname(__FILE__), 'aasm', file) }

# load the deprecated methods and modules
Dir[File.join(File.dirname(__FILE__), 'aasm', 'deprecated', '*.rb')].sort.each { |f| require File.expand_path(f) }

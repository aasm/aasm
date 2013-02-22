require 'ostruct'

# TODO shorten this [thorsten, 2011-12-20]
require File.join(File.dirname(__FILE__), 'aasm', 'version')
require File.join(File.dirname(__FILE__), 'aasm', 'errors')
require File.join(File.dirname(__FILE__), 'aasm', 'base')
require File.join(File.dirname(__FILE__), 'aasm', 'instance_base')
require File.join(File.dirname(__FILE__), 'aasm', 'transition')
require File.join(File.dirname(__FILE__), 'aasm', 'event')
require File.join(File.dirname(__FILE__), 'aasm', 'state')
require File.join(File.dirname(__FILE__), 'aasm', 'localizer')
require File.join(File.dirname(__FILE__), 'aasm', 'state_machine')
require File.join(File.dirname(__FILE__), 'aasm', 'persistence')
require File.join(File.dirname(__FILE__), 'aasm', 'aasm')

# load the deprecated methods and modules
Dir[File.join(File.dirname(__FILE__), 'aasm', 'deprecated', '*.rb')].sort.each { |f| require File.expand_path(f) }

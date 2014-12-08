# Migrating from _AASM_ version 3 to 4

## Must

### Callback order has been changed

The first callback to be run is `:before` of the event. A state's `:before_exit` callback
is now run directly before its `:exit` callback. Event-based guards are now run before
any of the transition guards are run. And finally, before running any state callbacks,
all (event- and transition-based) guards are run to check whether the state callbacks
can be run or not.


### Callback `:on_transition` renamed to `:after` and changed its binding

The transition callback `:on_transition` has been renamed to `:after` in order
to make clear it is being called (namely _after_ doing the transition).

Furthermore, in alignment with the other callbacks, it's not receiving the object
at hand as first parameter and binds the current object to self.

In summary, change from

```ruby
  aasm do
    ...
      transitions :from => :from_state, :to => :to_state, :on_transition => :do_something
    ...
  end

  ...
  def some_other_method(arg)
    ...
  end

  def do_something(obj, arg1, arg2)
    obj.some_other_method(arg1)
  end
```

to

```ruby
  aasm do
    ...
      transitions :from => :from_state, :to => :to_state, :after => :do_something
    ...
  end

  ...
  def some_other_method(arg)
    ...
  end

  def do_something(arg1, arg2)
    some_other_method(arg1) # run on the object as self
  end
```


### `after_commit` hooks are now event-based

The `after_commit` hooks have been move from the state level to the event level.
So, if you want some code block to be executed after the _AASM_ state has been
saved **AND** committed, change this code

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running, :after_commit => :notify_about_running_job

    event :run do
      transitions :from => :sleeping, :to => :running
    end
  end

  def notify_about_running_job
    ...
  end
end
```

to

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running

    event :run, :after_commit => :notify_about_running_job do
      transitions :from => :sleeping, :to => :running
    end
  end

  def notify_about_running_job
    ...
  end
end
```


### Instance-level inspection

Listing events for the current state now returns Event objects instead of event names (as symbols). So, change from

```ruby
job = Job.new

job.aasm.events
# => [:run]
```

to

```ruby
job = Job.new

job.aasm.events.map(&:name)
# => [:run]
```

Retrieving the list of permitted events has now been integrated into the `events` method. Change from

```ruby
job = Job.new

job.aasm.permissible_events
# => [:run]
```

to

```ruby
job = Job.new

job.aasm.events(:permitted => true).map(&:name)
# => [:run]
```

Class-based events now return a list of `Event` instances. Change from

```ruby
Job.aasm.events.values.map(&:name)
# => [:run]
```

to

```ruby
Job.aasm.events.map(&:name)
# => [:run]
```


## Could

### Triggering an event without _to_state_

When providing parameters to callbacks it is not required to provide the `to_state`
anymore. So, assuming you have the following class:

```ruby
class Job
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :from => :sleeping, :to => :running, :after => :log
    end
  end

  def log(message)
    logger.info message
  end
end
```

then you could change from

```ruby
job = Job.new
job.run(:running, "we want to run")
```

to this:

```ruby
job = Job.new
job.run("we want to run")

job.run(:running, "we want to run") # still supported to select the target state (the _to_state_)
```

On the other hand, you have to accept the arguments for **all** callback methods (and procs)
you provide and use. If you don't want to provide these, you can splat them

```ruby
def before(*args); end
# or
def before(*_); end # to indicate that you don't want to use the arguments
```

### New configuration option: `no_direct_assignment`

If you want to make sure that the _AASM_ column for storing the state is not directly assigned,
configure _AASM_ to not allow direct assignment, like this:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm :no_direct_assignment => true do
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :from => :sleeping, :to => :running
    end
  end

end
```

resulting in this:

```ruby
job = Job.create
job.aasm_state # => 'sleeping'
job.aasm_state = :running # => raises AASM::NoDirectAssignmentError
job.aasm_state # => 'sleeping'
```

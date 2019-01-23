# AASM - Ruby state machines

[![Gem Version](https://badge.fury.io/rb/aasm.svg)](http://badge.fury.io/rb/aasm)
[![Build Status](https://travis-ci.org/aasm/aasm.svg?branch=master)](https://travis-ci.org/aasm/aasm)
[![Code Climate](https://codeclimate.com/github/aasm/aasm/badges/gpa.svg)](https://codeclimate.com/github/aasm/aasm)

## Index
- [Upgrade from version 3 to 4](#upgrade-from-version-3-to-4)
- [Usage](#usage)
  - [Callbacks](#callbacks)
    - [Lifecycle](#lifecycle)
    - [The current event triggered](#the-current-event-triggered)
  - [Guards](#guards)
  - [Transitions](#transitions)
  - [Multiple state machines per class](#multiple-state-machines-per-class)
    - [Handling naming conflicts between multiple state machines](#handling-naming-conflicts-between-multiple-state-machines)
    - [Binding event](#binding-event)
  - [Auto-generated Status Constants](#auto-generated-status-constants)
  - [Extending AASM](#extending-aasm)
  - [ActiveRecord](#activerecord)
  - [Bang events](#bang-events)
  - [ActiveRecord enums](#activerecord-enums)
  - [Sequel](#sequel)
  - [Dynamoid](#dynamoid)
  - [Mongoid](#mongoid)
  - [Nobrainer](#nobrainer)
  - [Redis](#redis)
  - [Automatic Scopes](#automatic-scopes)
  - [Transaction support](#transaction-support)
  - [Pessimistic Locking](#pessimistic-locking)
  - [Column name & migration](#column-name--migration)
  - [Inspection](#inspection)
  - [Warning output](#warning-output)
  - [RubyMotion support](#rubymotion-support)
  - [Testing](#testing)
    - [RSpec](#rspec)
    - [Minitest](#minitest)
      - [Assertions](#assertions)
      - [Expectations](#expectations)
 - [Installation](#installation)
   - [Manually from RubyGems.org](#manually-from-rubygemsorg)
   - [Bundler](#or-if-you-are-using-bundler)
   - [Building your own gems](#building-your-own-gems)
  - [Generators](#generators)
  - [Test suite with Docker](#docker)
  - [Latest changes](#latest-changes)
  - [Questions?](#questions)
  - [Maintainers](#maintainers)
- [Contributing](CONTRIBUTING.md)
- [Warranty](#warranty)
- [License](#license)

This package contains AASM, a library for adding finite state machines to Ruby classes.

AASM started as the *acts_as_state_machine* plugin but has evolved into a more generic library
that no longer targets only ActiveRecord models. It currently provides adapters for many
ORMs but it can be used for any Ruby class, no matter what parent class it has (if any).

## Upgrade from version 3 to 4

Take a look at the [README_FROM_VERSION_3_TO_4](https://github.com/aasm/aasm/blob/master/README_FROM_VERSION_3_TO_4.md) for details how to switch from version 3.x to 4.0 of _AASM_.

## Usage

Adding a state machine is as simple as including the AASM module and start defining
**states** and **events** together with their **transitions**:

```ruby
class Job
  include AASM

  aasm do
    state :sleeping, initial: true
    state :running, :cleaning

    event :run do
      transitions from: :sleeping, to: :running
    end

    event :clean do
      transitions from: :running, to: :cleaning
    end

    event :sleep do
      transitions from: [:running, :cleaning], to: :sleeping
    end
  end

end
```

This provides you with a couple of public methods for instances of the class `Job`:

```ruby
job = Job.new
job.sleeping? # => true
job.may_run?  # => true
job.run
job.running?  # => true
job.sleeping? # => false
job.may_run?  # => false
job.run       # => raises AASM::InvalidTransition
```

If you don't like exceptions and prefer a simple `true` or `false` as response, tell
AASM not to be *whiny*:

```ruby
class Job
  ...
  aasm whiny_transitions: false do
    ...
  end
end

job.running?  # => true
job.may_run?  # => false
job.run       # => false
```

When firing an event, you can pass a block to the method, it will be called only if
the transition succeeds :

```ruby
  job.run do
    job.user.notify_job_ran # Will be called if job.may_run? is true
  end
```

### Callbacks

You can define a number of callbacks for your events, transitions and states. These methods, Procs or classes will be
called when certain criteria are met, like entering a particular state:

```ruby
class Job
  include AASM

  aasm do
    state :sleeping, initial: true, before_enter: :do_something
    state :running, before_enter: Proc.new { do_something && notify_somebody }
    state :finished

    after_all_transitions :log_status_change

    event :run, after: :notify_somebody do
      before do
        log('Preparing to run')
      end

      transitions from: :sleeping, to: :running, after: Proc.new {|*args| set_process(*args) }
      transitions from: :running, to: :finished, after: LogRunTime
    end

    event :sleep do
      after do
        ...
      end
      error do |e|
        ...
      end
      transitions from: :running, to: :sleeping
    end
  end

  def log_status_change
    puts "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
  end

  def set_process(name)
    ...
  end

  def do_something
    ...
  end

  def notify_somebody
    ...
  end

end

class LogRunTime
  def call
    log "Job was running for X seconds"
  end
end
```

In this case `do_something` is called before actually entering the state `sleeping`,
while `notify_somebody` is called after the transition `run` (from `sleeping` to `running`)
is finished.

AASM will also initialize `LogRunTime` and run the `call` method for you after the transition from `running` to `finished` in the example above. You can pass arguments to the class by defining an initialize method on it, like this:

Note that Procs are executed in the context of a record, it means that you don't need to expect the record as an argument, just call the methods you need.

```ruby
class LogRunTime
  # optional args parameter can be omitted, but if you define initialize
  # you must accept the model instance as the first parameter to it.
  def initialize(job, args = {})
    @job = job
  end

  def call
    log "Job was running for #{@job.run_time} seconds"
  end
end
```

Also, you can pass parameters to events:

```ruby
  job = Job.new
  job.run(:running, :defragmentation)
```

In this case the `set_process` would be called with `:defragmentation` argument.

Note that when passing arguments to a state transition, the first argument should be the desired end state. In the above example, we wish to transition to `:running` state and run the callback with `:defragmentation` argument. You can also omit or pass in `nil` as the desired end state, and AASM will try to transition to the first end state defined for that event.

In case of an error during the event processing the error is rescued and passed to `:error`
callback, which can handle it or re-raise it for further propagation.

Also, you can define a method that will be called if any event fails:

```ruby
def aasm_event_failed(event_name, old_state_name)
  # use custom exception/messages, report metrics, etc
end
```

During the transition's `:after` callback (and reliably only then, or in the global
`after_all_transitions` callback) you can access the originating state (the from-state)
and the target state (the to state), like this:

```ruby
  def set_process(name)
    logger.info "from #{aasm.from_state} to #{aasm.to_state}"
  end
```

#### Lifecycle

Here you can see a list of all possible callbacks, together with their order of calling:

```ruby
begin
  event           before_all_events
  event           before
  event           guards
  transition      guards
  old_state       before_exit
  old_state       exit
                  after_all_transitions
  transition      after
  new_state       before_enter
  new_state       enter
  ...update state...
  event           before_success      # if persist successful
  transition      success             # if persist successful
  event           success             # if persist successful
  old_state       after_exit
  new_state       after_enter
  event           after
  event           after_all_events
rescue
  event           error
  event           error_on_all_events
ensure
  event           ensure
  event           ensure_on_all_events
end
```

#### The current event triggered

While running the callbacks you can easily retrieve the name of the event triggered
by using `aasm.current_event`:

```ruby
  # taken the example callback from above
  def do_something
    puts "triggered #{aasm.current_event}"
  end
```

and then

```ruby
  job = Job.new

  # without bang
  job.sleep # => triggered :sleep

  # with bang
  job.sleep! # => triggered :sleep!
```


### Guards

Let's assume you want to allow particular transitions only if a defined condition is
given. For this you can set up a guard per transition, which will run before actually
running the transition. If the guard returns `false` the transition will be
denied (raising `AASM::InvalidTransition` or returning `false` itself):

```ruby
class Cleaner
  include AASM

  aasm do
    state :idle, initial: true
    state :cleaning

    event :clean do
      transitions from: :idle, to: :cleaning, guard: :cleaning_needed?
    end

    event :clean_if_needed do
      transitions from: :idle, to: :cleaning do
        guard do
          cleaning_needed?
        end
      end
      transitions from: :idle, to: :idle
    end

    event :clean_if_dirty do
      transitions from: :idle, to: :cleaning, guard: :if_dirty?
    end
  end

  def cleaning_needed?
    false
  end

  def if_dirty?(status)
    status == :dirty
  end
end

job = Cleaner.new
job.may_clean?            # => false
job.clean                 # => raises AASM::InvalidTransition
job.may_clean_if_needed?  # => true
job.clean_if_needed!      # idle

job.clean_if_dirty(:clean) # => false
job.clean_if_dirty(:dirty) # => true
```

You can even provide a number of guards, which all have to succeed to proceed

```ruby
    def walked_the_dog?; ...; end

    event :sleep do
      transitions from: :running, to: :sleeping, guards: [:cleaning_needed?, :walked_the_dog?]
    end
```

If you want to provide guards for all transitions within an event, you can use event guards

```ruby
    event :sleep, guards: [:walked_the_dog?] do
      transitions from: :running, to: :sleeping, guards: [:cleaning_needed?]
      transitions from: :cleaning, to: :sleeping
    end
```

If you prefer a more Ruby-like guard syntax, you can use `if` and `unless` as well:

```ruby
    event :clean do
      transitions from: :running, to: :cleaning, if: :cleaning_needed?
    end

    event :sleep do
      transitions from: :running, to: :sleeping, unless: :cleaning_needed?
    end
  end
```

You can invoke a Class instead a method since this Class responds to `call`

```ruby
    event :sleep do
      transitions from: :running, to: :sleeping, guards: Dog
    end
```
```ruby
  class Dog
    def call
      cleaning_needed? && walked?
    end
    ...
  end
```

### Transitions

In the event of having multiple transitions for an event, the first transition that successfully completes will stop other transitions in the same event from being processed.

```ruby
require 'aasm'

class Job
  include AASM

  aasm do
    state :stage1, initial: true
    state :stage2
    state :stage3
    state :completed

    event :stage1_completed do
      transitions from: :stage1, to: :stage3, guard: :stage2_completed?
      transitions from: :stage1, to: :stage2
    end
  end

  def stage2_completed?
    true
  end
end

job = Job.new
job.stage1_completed
job.aasm.current_state # stage3
```


### Multiple state machines per class

Multiple state machines per class are supported. Be aware though that _AASM_ has been
built with one state machine per class in mind. Nonetheless, here's how to do it:

```ruby
class SimpleMultipleExample
  include AASM
  aasm(:move) do
    state :standing, initial: true
    state :walking
    state :running

    event :walk do
      transitions from: :standing, to: :walking
    end
    event :run do
      transitions from: [:standing, :walking], to: :running
    end
    event :hold do
      transitions from: [:walking, :running], to: :standing
    end
  end

  aasm(:work) do
    state :sleeping, initial: true
    state :processing

    event :start do
      transitions from: :sleeping, to: :processing
    end
    event :stop do
      transitions from: :processing, to: :sleeping
    end
  end
end

simple = SimpleMultipleExample.new

simple.aasm(:move).current_state
# => :standing
simple.aasm(:work).current
# => :sleeping

simple.start
simple.aasm(:move).current_state
# => :standing
simple.aasm(:work).current
# => :processing

```

#### Handling naming conflicts between multiple state machines

_AASM_ doesn't prohibit to define the same event in more than one state
machine. If no namespace is provided, the latest definition "wins" and
overrides previous definitions. Nonetheless, a warning is issued:
`SimpleMultipleExample: overriding method 'run'!`.

Alternatively, you can provide a namespace for each state machine:

```ruby
class NamespacedMultipleExample
  include AASM
  aasm(:status) do
    state :unapproved, initial: true
    state :approved

    event :approve do
      transitions from: :unapproved, to: :approved
    end

    event :unapprove do
      transitions from: :approved, to: :unapproved
    end
  end

  aasm(:review_status, namespace: :review) do
    state :unapproved, initial: true
    state :approved

    event :approve do
      transitions from: :unapproved, to: :approved
    end

    event :unapprove do
      transitions from: :approved, to: :unapproved
    end
  end
end

namespaced = NamespacedMultipleExample.new

namespaced.aasm(:status).current_state
# => :unapproved
namespaced.aasm(:review_status).current_state
# => :unapproved
namespaced.approve_review
namespaced.aasm(:review_status).current_state
# => :approved
```

All _AASM_ class- and instance-level `aasm` methods accept a state machine selector.
So, for example, to use inspection on a class level, you have to use

```ruby
SimpleMultipleExample.aasm(:move).states.map(&:name)
# => [:standing, :walking, :running]
```

### Binding event

Allow an event to be bound to another
```ruby
class Example
  include AASM

  aasm(:work) do
    state :sleeping, initial: true
    state :processing

    event :start do
      transitions from: :sleeping, to: :processing
    end
    event :stop do
      transitions from: :processing, to: :sleeping
    end
  end

  aasm(:question) do
    state :answered, initial: true
    state :asked

    event :ask, binding_event: :start do
      transitions from: :answered, to: :asked
    end
    event :answer, binding_event: :stop do
      transitions from: :asked, to: :answered
    end
  end
end

example = Example.new
example.aasm(:work).current_state #=> :sleeping
example.aasm(:question).current_state #=> :answered
example.ask
example.aasm(:work).current_state #=> :processing
example.aasm(:question).current_state #=> :asked
```

### Auto-generated Status Constants

AASM automatically [generates constants](https://github.com/aasm/aasm/pull/60)
for each status so you don't have to explicitly define them.

```ruby
class Foo
  include AASM

  aasm do
    state :initialized
    state :calculated
    state :finalized
  end
end

> Foo::STATE_INITIALIZED
#=> :initialized
> Foo::STATE_CALCULATED
#=> :calculated
```

### Extending AASM

AASM allows you to easily extend `AASM::Base` for your own application purposes.

Let's suppose we have common logic across many AASM models. We can embody this logic in a sub-class of `AASM::Base`.

```ruby
class CustomAASMBase < AASM::Base
  # A custom transiton that we want available across many AASM models.
  def count_transitions!
    klass.class_eval do
      aasm with_klass: CustomAASMBase do
        after_all_transitions :increment_transition_count
      end
    end
  end

  # A custom annotation that we want available across many AASM models.
  def requires_guards!
    klass.class_eval do
      attr_reader :authorizable_called,
        :transition_count,
        :fillable_called

      def authorizable?
        @authorizable_called = true
      end

      def fillable?
        @fillable_called = true
      end

      def increment_transition_count
        @transition_count ||= 0
        @transition_count += 1
      end
    end
  end
end
```

When we declare our model that has an AASM state machine, we simply declare the AASM block with a `:with_klass` key to our own class.

```ruby
class SimpleCustomExample
  include AASM

  # Let's build an AASM state machine with our custom class.
  aasm with_klass: CustomAASMBase do
    requires_guards!
    count_transitions!

    state :initialised, initial: true
    state :filled_out
    state :authorised

    event :fill_out do
      transitions from: :initialised, to: :filled_out, guard: :fillable?
    end
    event :authorise do
      transitions from: :filled_out, to: :authorised, guard: :authorizable?
    end
  end
end
```


### ActiveRecord

AASM comes with support for ActiveRecord and allows automatic persisting of the object's
state in the database.

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do # default column: aasm_state
    state :sleeping, initial: true
    state :running

    event :run do
      transitions from: :sleeping, to: :running
    end

    event :sleep do
      transitions from: :running, to: :sleeping
    end
  end

end
```

### Bang events

You can tell AASM to auto-save the object or leave it unsaved

```ruby
job = Job.new
job.run   # not saved
job.run!  # saved

# or
job.aasm.fire(:run) # not saved
job.aasm.fire!(:run) # saved
```

Saving includes running all validations on the `Job` class. If
`whiny_persistence` flag is set to `true`, exception is raised in case of
failure. If `whiny_persistence` flag is set to false, methods with a bang return
`true` if the state transition is successful or `false` if an error occurs.

If you want make sure the state gets saved without running validations (and
thereby maybe persisting an invalid object state), simply tell AASM to skip the
validations. Be aware that when skipping validations, only the state column will
be updated in the database (just like ActiveRecord `update_column` is working).

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm skip_validation_on_save: true do
    state :sleeping, initial: true
    state :running

    event :run do
      transitions from: :sleeping, to: :running
    end

    event :sleep do
      transitions from: :running, to: :sleeping
    end
  end

end
```

If you want to make sure that the _AASM_ column for storing the state is not directly assigned,
configure _AASM_ to not allow direct assignment, like this:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm no_direct_assignment: true do
    state :sleeping, initial: true
    state :running

    event :run do
      transitions from: :sleeping, to: :running
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

#### ActiveRecord enums

You can use
[enumerations](http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html)
in Rails 4.1+ for your state column:

```ruby
class Job < ActiveRecord::Base
  include AASM

  enum state: {
    sleeping: 5,
    running: 99
  }

  aasm column: :state, enum: true do
    state :sleeping, initial: true
    state :running
  end
end
```

You can explicitly pass the name of the method which provides access
to the enumeration mapping as a value of ```enum```, or you can simply
set it to ```true```. In the latter case AASM will try to use
pluralized column name to access possible enum states.

Furthermore, if your column has integer type (which is normally the
case when you're working with Rails enums), you can omit ```:enum```
setting --- AASM auto-detects this situation and enabled enum
support. If anything goes wrong, you can disable enum functionality
and fall back to the default behavior by setting ```:enum```
to ```false```.

### Sequel

AASM also supports [Sequel](http://sequel.jeremyevans.net/) besides _ActiveRecord_, and _Mongoid_.

```ruby
class Job < Sequel::Model
  include AASM

  aasm do # default column: aasm_state
    ...
  end
end
```

However it's not yet as feature complete as _ActiveRecord_. For example, there are
scopes defined yet. See [Automatic Scopes](#automatic-scopes).

### Dynamoid

Since version `4.8.0` _AASM_ also supports [Dynamoid](http://joshsymonds.com/Dynamoid/) as
persistence ORM.

### Mongoid

AASM also supports persistence to Mongodb if you're using Mongoid. Make sure
to include Mongoid::Document before you include AASM.

```ruby
class Job
  include Mongoid::Document
  include AASM
  field :aasm_state
  aasm do
    ...
  end
end
```

### NoBrainer

AASM also supports persistence to [RethinkDB](https://www.rethinkdb.com/)
if you're using [Nobrainer](http://nobrainer.io/).
Make sure to include NoBrainer::Document before you include AASM.

```ruby
class Job
  include NoBrainer::Document
  include AASM
  field :aasm_state
  aasm do
    ...
  end
end
```

### Redis

AASM also supports persistence in Redis via
[Redis::Objects](https://github.com/nateware/redis-objects).
Make sure to include Redis::Objects before you include AASM. Note that non-bang
events will work as bang events, persisting the changes on every call.

```ruby
class User
  include Redis::Objects
  include AASM

  aasm do
  end
end
```

### Automatic Scopes

AASM will automatically create scope methods for each state in the model.

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do
    state :sleeping, initial: true
    state :running
    state :cleaning
  end

  def self.sleeping
    "This method name is already in use"
  end
end
```

```ruby
class JobsController < ApplicationController
  def index
    @running_jobs = Job.running
    @recent_cleaning_jobs = Job.cleaning.where('created_at >=  ?', 3.days.ago)

    # @sleeping_jobs = Job.sleeping   #=> "This method name is already in use"
  end
end
```

If you don't need scopes (or simply don't want them), disable their creation when
defining the `AASM` states, like this:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm create_scopes: false do
    state :sleeping, initial: true
    state :running
    state :cleaning
  end
end
```


### Transaction support

Since version *3.0.13* AASM supports ActiveRecord transactions. So whenever a transition
callback or the state update fails, all changes to any database record are rolled back.
Mongodb does not support transactions.

There are currently 3 transactional callbacks that can be handled on the event, and 2 transactional callbacks for all events.

```ruby
  event           before_all_transactions
  event           before_transaction
  event           aasm_fire_event (within transaction)
  event           after_commit (if event successful)
  event           after_transaction
  event           after_all_transactions
```

If you want to make sure a depending action happens only after the transaction is committed,
use the `after_commit` callback along with the auto-save (bang) methods, like this:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do
    state :sleeping, initial: true
    state :running

    event :run, after_commit: :notify_about_running_job do
      transitions from: :sleeping, to: :running
    end
  end

  def notify_about_running_job
    ...
  end
end

job = Job.where(state: 'sleeping').first!
job.run! # Saves the model and triggers the after_commit callback
```

Note that the following will not run the `after_commit` callbacks because
the auto-save method is not used:

```ruby
job = Job.where(state: 'sleeping').first!
job.run
job.save! #notify_about_running_job is not run
```

If you want to encapsulate state changes within an own transaction, the behavior
of this nested transaction might be confusing. Take a look at
[ActiveRecord Nested Transactions](http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html)
if you want to know more about this. Nevertheless, AASM by default requires a new transaction
`transaction(requires_new: true)`. You can override this behavior by changing
the configuration

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm requires_new_transaction: false do
    ...
  end

  ...
end
```

which then leads to `transaction(requires_new: false)`, the Rails default.

Additionally, if you do not want any of your active record actions to be
wrapped in a transaction, you can specify the `use_transactions` flag. This can
be useful if you want want to persist things to the database that happen as a
result of a transaction or callback, even when some error occurs. The
`use_transactions` flag is true by default.

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm use_transactions: false do
    ...
  end

  ...
end
```

### Pessimistic Locking

AASM supports [Active Record pessimistic locking via `with_lock`](http://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html#method-i-with_lock) for database persistence layers.

| Option | Purpose |
| ------ | ------- |
| `false` (default) | No lock is obtained | |
| `true` | Obtain a blocking pessimistic lock e.g. `FOR UPDATE` |
| String | Obtain a lock based on the SQL string e.g. `FOR UPDATE NOWAIT` |


```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm requires_lock: true do
    ...
  end

  ...
end
```

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm requires_lock: 'FOR UPDATE NOWAIT' do
    ...
  end

  ...
end
```


### Column name & migration

As a default AASM uses the column `aasm_state` to store the states. You can override
this by defining your favorite column name, using `:column` like this:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm column: 'my_state' do
    ...
  end

  aasm :another_state_machine, column: 'second_state' do
    ...
  end
end
```

Whatever column name is used, make sure to add a migration to provide this column
(of type `string`):

```ruby
class AddJobState < ActiveRecord::Migration
  def self.up
    add_column :jobs, :aasm_state, :string
  end

  def self.down
    remove_column :jobs, :aasm_state
  end
end
```

### Inspection

AASM supports query methods for states and events

Given the following `Job` class:

```ruby
class Job
  include AASM

  aasm do
    state :sleeping, initial: true
    state :running, :cleaning

    event :run do
      transitions from: :sleeping, to: :running
    end

    event :clean do
      transitions from: :running, to: :cleaning, guard: :cleaning_needed?
    end

    event :sleep do
      transitions from: [:running, :cleaning], to: :sleeping
    end
  end

  def cleaning_needed?
    false
  end
end
```

```ruby
# show all states
Job.aasm.states.map(&:name)
#=> [:sleeping, :running, :cleaning]

job = Job.new

# show all permitted states (from initial state)
job.aasm.states(permitted: true).map(&:name)
#=> [:running]

job.run
job.aasm.states(permitted: true).map(&:name)
#=> [:sleeping]

# show all non permitted states
job.aasm.states(permitted: false).map(&:name)
#=> [:cleaning]

# show all possible (triggerable) events from the current state
job.aasm.events.map(&:name)
#=> [:clean, :sleep]

# show all permitted events
job.aasm.events(permitted: true).map(&:name)
#=> [:sleep]

# show all non permitted events
job.aasm.events(permitted: false).map(&:name)
#=> [:clean]

# show all possible events except a specific one
job.aasm.events(reject: :sleep).map(&:name)
#=> [:clean]

# list states for select
Job.aasm.states_for_select
#=> [["Sleeping", "sleeping"], ["Running", "running"], ["Cleaning", "cleaning"]]

# show permitted states with guard parameter
job.aasm.states({permitted: true}, guard_parameter).map(&:name)
```


### Warning output

Warnings are by default printed to `STDERR`. If you want to log those warnings to another output,
use

```ruby
class Job
  include AASM

  aasm logger: Rails.logger do
    ...
  end
end
```

You can hide warnings by setting `AASM::Configuration.hide_warnings = true`

### RubyMotion support

Now supports [CodeDataQuery](https://github.com/infinitered/cdq.git) !
However I'm still in the process of submitting my compatibility updates to their repository.
In the meantime you can use [my fork](https://github.com/Infotaku/cdq.git), there may still be some minor issues but I intend to extensively use it myself, so fixes should come fast.

Warnings:
- Due to RubyMotion Proc's lack of 'source_location' method, it may be harder
to find out the origin of a "cannot transition from" error. I would recommend using
the 'instance method symbol / string' way whenever possible when defining guardians and callbacks.


### Testing

#### RSpec

AASM provides some matchers for [RSpec](http://rspec.info):
*`transition_from`,
* `have_state`, `allow_event`
* and `allow_transition_to`.

##### Installation Instructions:
* Add `require 'aasm/rspec'` to your `spec_helper.rb` file.

##### Examples Of Usage in Rspec:

```ruby
# classes with only the default state machine
job = Job.new
expect(job).to transition_from(:sleeping).to(:running).on_event(:run)
expect(job).not_to transition_from(:sleeping).to(:cleaning).on_event(:run)
expect(job).to have_state(:sleeping)
expect(job).not_to have_state(:running)
expect(job).to allow_event :run
expect(job).to_not allow_event :clean
expect(job).to allow_transition_to(:running)
expect(job).to_not allow_transition_to(:cleaning)
# on_event also accept multiple arguments
expect(job).to transition_from(:sleeping).to(:running).on_event(:run, :defragmentation)

# classes with multiple state machine
multiple = SimpleMultipleExample.new
expect(multiple).to transition_from(:standing).to(:walking).on_event(:walk).on(:move)
expect(multiple).to_not transition_from(:standing).to(:running).on_event(:walk).on(:move)
expect(multiple).to have_state(:standing).on(:move)
expect(multiple).not_to have_state(:walking).on(:move)
expect(multiple).to allow_event(:walk).on(:move)
expect(multiple).to_not allow_event(:hold).on(:move)
expect(multiple).to allow_transition_to(:walking).on(:move)
expect(multiple).to_not allow_transition_to(:running).on(:move)
expect(multiple).to transition_from(:sleeping).to(:processing).on_event(:start).on(:work)
expect(multiple).to_not transition_from(:sleeping).to(:sleeping).on_event(:start).on(:work)
expect(multiple).to have_state(:sleeping).on(:work)
expect(multiple).not_to have_state(:processing).on(:work)
expect(multiple).to allow_event(:start).on(:move)
expect(multiple).to_not allow_event(:stop).on(:move)
expect(multiple).to allow_transition_to(:processing).on(:move)
expect(multiple).to_not allow_transition_to(:sleeping).on(:move)
# allow_event also accepts arguments
expect(job).to allow_event(:run).with(:defragmentation)

```

#### Minitest

AASM provides assertions and rspec-like expectations for [Minitest](https://github.com/seattlerb/minitest).

##### Assertions

List of supported assertions: `assert_have_state`, `refute_have_state`, `assert_transitions_from`, `refute_transitions_from`, `assert_event_allowed`, `refute_event_allowed`, `assert_transition_to_allowed`, `refute_transition_to_allowed`.


##### Examples Of Usage (Minitest):

Add `require 'aasm/minitest'` to your `test_helper.rb` file and use them like this:

```ruby
# classes with only the default state machine
job = Job.new
assert_transitions_from job, :sleeping, to: :running, on_event: :run
refute_transitions_from job, :sleeping, to: :cleaning, on_event: :run
assert_have_state job, :sleeping
refute_have_state job, :running
assert_event_allowed job, :run
refute_event_allowed job, :clean
assert_transition_to_allowed job, :running
refute_transition_to_allowed job, :cleaning
# on_event also accept arguments
assert_transitions_from job, :sleeping, :defragmentation, to: :running, on_event: :run

# classes with multiple state machine
multiple = SimpleMultipleExample.new
assert_transitions_from multiple, :standing, to: :walking, on_event: :walk, on: :move
refute_transitions_from multiple, :standing, to: :running, on_event: :walk, on: :move
assert_have_state multiple, :standing, on: :move
refute_have_state multiple, :walking, on: :move
assert_event_allowed multiple, :walk, on: :move
refute_event_allowed multiple, :hold, on: :move
assert_transition_to_allowed multiple, :walking, on: :move
refute_transition_to_allowed multiple, :running, on: :move
assert_transitions_from multiple, :sleeping, to: :processing, on_event: :start, on: :work
refute_transitions_from multiple, :sleeping, to: :sleeping, on_event: :start, on: :work
assert_have_state multiple, :sleeping, on: :work
refute_have_state multiple, :processing, on: :work
assert_event_allowed multiple, :start, on: :move
refute_event_allowed multiple, :stop, on: :move
assert_transition_to_allowed multiple, :processing, on: :move
refute_transition_to_allowed multiple, :sleeping, on: :move
```

##### Expectations

List of supported expectations: `must_transition_from`, `wont_transition_from`, `must_have_state`, `wont_have_state`, `must_allow_event`, `wont_allow_event`, `must_allow_transition_to`, `wont_allow_transition_to`.

Add `require 'aasm/minitest_spec'` to your `test_helper.rb` file and use them like this:

```ruby
# classes with only the default state machine
job = Job.new
job.must_transition_from :sleeping, to: :running, on_event: :run
job.wont_transition_from :sleeping, to: :cleaning, on_event: :run
job.must_have_state :sleeping
job.wont_have_state :running
job.must_allow_event :run
job.wont_allow_event :clean
job.must_allow_transition_to :running
job.wont_allow_transition_to :cleaning
# on_event also accept arguments
job.must_transition_from :sleeping, :defragmentation, to: :running, on_event: :run

# classes with multiple state machine
multiple = SimpleMultipleExample.new
multiple.must_transition_from :standing, to: :walking, on_event: :walk, on: :move
multiple.wont_transition_from :standing, to: :running, on_event: :walk, on: :move
multiple.must_have_state :standing, on: :move
multiple.wont_have_state :walking, on: :move
multiple.must_allow_event :walk, on: :move
multiple.wont_allow_event :hold, on: :move
multiple.must_allow_transition_to :walking, on: :move
multiple.wont_allow_transition_to :running, on: :move
multiple.must_transition_from :sleeping, to: :processing, on_event: :start, on: :work
multiple.wont_transition_from :sleeping, to: :sleeping, on_event: :start, on: :work
multiple.must_have_state :sleeping, on: :work
multiple.wont_have_state :processing, on: :work
multiple.must_allow_event :start, on: :move
multiple.wont_allow_event :stop, on: :move
multiple.must_allow_transition_to :processing, on: :move
multiple.wont_allow_transition_to :sleeping, on: :move
```

## <a id="installation">Installation ##

### Manually from RubyGems.org ###

```sh
% gem install aasm
```

### Or if you are using Bundler ###

```ruby
# Gemfile
gem 'aasm'
```

### Building your own gems ###

```sh
% rake build
% sudo gem install pkg/aasm-x.y.z.gem
```

### Generators

After installing AASM you can run generator:

```sh
% rails generate aasm NAME [COLUMN_NAME]
```
Replace NAME with the Model name, COLUMN_NAME is optional(default is 'aasm_state').
This will create a model (if one does not exist) and configure it with aasm block.
For Active record orm a migration file is added to add aasm state column to table.

### Docker

Run test suite easily on docker
```
1. docker-compose build aasm
2. docker-compose run --rm aasm
```

## Latest changes ##

Take a look at the [CHANGELOG](https://github.com/aasm/aasm/blob/master/CHANGELOG.md) for details about recent changes to the current version.

## Questions? ##

Feel free to

* [create an issue on GitHub](https://github.com/aasm/aasm/issues)
* [ask a question on StackOverflow](http://stackoverflow.com) (tag with `aasm`)
* send us a tweet [@aasm](http://twitter.com/aasm)

## Maintainers ##

* [Scott Barron](https://github.com/rubyist) (2006–2009, original author)
* [Travis Tilley](https://github.com/ttilley) (2009–2011)
* [Thorsten Böttger](http://github.com/alto) (since 2011)
* [Anil Maurya](http://github.com/anilmaurya) (since 2016)


## [Contributing](CONTRIBUTING.md)

## Warranty ##

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.

## License ##

Copyright (c) 2006-2017 Scott Barron

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

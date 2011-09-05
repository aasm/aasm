# AASM - Ruby state machines #

This package contains AASM, a library for adding finite state machines to Ruby classes.

AASM started as the acts_as_state_machine plugin but has evolved into a more generic library that no longer targets only ActiveRecord models.

## Features ##

* States
* Machines
* Events
* Transitions

## New Callbacks ##

The callback chain & order on a successful event looks like:

    oldstate:exit*
      event:before
        __find transition, if possible__
        transition:on_transition*
          oldstate:before_exit
            newstate:before_enter
              newstate:enter*
              __update state__
              event:success*
            oldstate:after_exit
          newstate:after_enter
      event:after
    obj:aasm_event_fired*

    (*) marks old callbacks


## Download ##

The latest AASM can currently be pulled from the git repository on github.

* http://github.com/rubyist/aasm/tree/master


## Installation ##

### From RubyGems.org ###

```sh
% gem install aasm
```

### Building your own gems ###

```sh
% rake build
% sudo gem install pkg/aasm-x.y.z.gem
```

## Simple Example ##

Here's a quick example highlighting some of the features.

```ruby
  class Conversation
    include AASM

    aasm_column :current_state # defaults to aasm_state

    aasm_initial_state :unread

    aasm_state :unread
    aasm_state :read
    aasm_state :closed


    aasm_event :view do
      transitions :to => :read, :from => [:unread]
    end

    aasm_event :close do
      transitions :to => :closed, :from => [:read, :unread]
    end
  end
```

## A Slightly More Complex Example ##

This example uses a few of the more complex features available.

```ruby
  class Relationship
    include AASM

    aasm_column :status
    
    aasm_initial_state Proc.new { |relationship| relationship.strictly_for_fun? ? :intimate : :dating }
    
    aasm_state :dating,   :enter => :make_happy,        :exit => :make_depressed
    aasm_state :intimate, :enter => :make_very_happy,   :exit => :never_speak_again
    aasm_state :married,  :enter => :give_up_intimacy,  :exit => :buy_exotic_car_and_wear_a_combover
    
    aasm_event :get_intimate do
      transitions :to => :intimate, :from => [:dating], :guard => :drunk?
    end
    
    aasm_event :get_married do
      transitions :to => :married, :from => [:dating, :intimate], :guard => :willing_to_give_up_manhood?
    end
    
    def strictly_for_fun?; end
    def drunk?; end
    def willing_to_give_up_manhood?; end
    def make_happy; end
    def make_depressed; end
    def make_very_happy; end
    def never_speak_again; end
    def give_up_intimacy; end
    def buy_exotic_car_and_wear_a_combover; end
  end
```

## Callbacks around events
```ruby
  class Relationship
    include AASM

    aasm_state :dating
    aasm_state :married

    aasm_event :get_married,
      :before => :make_vows,
      :after => :eat_wedding_cake do
      transitions :to => :married, :from => [:dating]
    end
  end
```


# Other Stuff #

Author::  Scott Barron <scott at elitists dot net>
License:: Original code Copyright 2006, 2007, 2008 by Scott Barron.
          Released under an MIT-style license.  See the LICENSE  file
          included in the distribution.

## Warranty ##

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.

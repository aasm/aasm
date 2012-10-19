# AASM - Ruby state machines [![Build Status](https://secure.travis-ci.org/aasm/aasm.png)](http://travis-ci.org/aasm/aasm) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/aasm/aasm)

This package contains AASM, a library for adding finite state machines to Ruby classes.

AASM started as the acts_as_state_machine plugin but has evolved into a more generic library
that no longer targets only ActiveRecord models. It currently provides adapters for
[ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html) and
[Mongoid](http://mongoid.org/).

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


## Installation ##

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

## Examples ##

### Simple Example ###

Here's a quick example highlighting some of the features.

```ruby
class Conversation
  include AASM

  aasm :column => :current_state do  # defaults to aasm_state
    state :unread, :initial => true
    state :read
    state :closed

    event :view do
      transitions :to => :read, :from => [:unread]
    end

    event :close do
      transitions :to => :closed, :from => [:read, :unread]
    end
  end

end
```

### A Slightly More Complex Example ###

This example uses a few of the more complex features available.

```ruby
  class Relationship
    include AASM

    aasm :column => :status do
      state :dating,   :enter => :make_happy,        :exit => :make_depressed
      state :intimate, :enter => :make_very_happy,   :exit => :never_speak_again
      state :married,  :enter => :give_up_intimacy,  :exit => :buy_exotic_car_and_wear_a_combover

      event :get_intimate do
        transitions :to => :intimate, :from => [:dating], :guard => :drunk?
      end

      # Will allow transitioning from any state if guard allows it
      event :get_married do
        transitions :to => :married, :guard => :willing_to_give_up_manhood?
      end
    end
    aasm_initial_state Proc.new { |relationship| relationship.strictly_for_fun? ? :intimate : :dating }

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

### Callbacks around events ###
```ruby
  class Relationship
    include AASM

    aasm do
      state :dating
      state :married

      event :get_married,
            :before => :make_vows,
            :after => :eat_wedding_cake do
        transitions :to => :married, :from => [:dating]
      end
    end
  end
```

### Persistence example ###
```ruby
  class InvalidPersistor < ActiveRecord::Base
    include AASM
    aasm :column => :status, :skip_validation_on_save => true do
      state :sleeping, :initial => true
      state :running
      event :run do
        transitions :to => :running, :from => :sleeping
      end
      event :sleep do
        transitions :to => :sleeping, :from => :running
      end
    end
    validates_presence_of :name
  end
```
This model can change AASM states which are stored into the database, even if the model itself is invalid!



## Changelog ##

Look at the [CHANGELOG](https://github.com/aasm/aasm/blob/master/CHANGELOG.md) for details.


## Authors ##

* [Scott Barron](https://github.com/rubyist)
* [Travis Tilley](https://github.com/ttilley)
* [Thorsten Böttger](http://github.com/alto)


## Warranty ##

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.

## License ##

Copyright (c) 2006-2012 Scott Barron

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

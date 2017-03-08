## Install dependency matrix

    appraisal install

This will re-generate Gemfiles in `gemfile` folder

Use rvm gemsets or similar to avoid global gem pollution

## Run specs

For all supported Rails/ORM combinations:

    appraisal rspec

Or for specific one:

    appraisal rails_4.2 rspec

Or for one particular test file

    appraisal rails_4.2_mongoid_5 rspec spec/unit/persistence/mongoid_persistence_multiple_spec.rb

Or down to one test case

    appraisal rails_4.2_mongoid_5 rspec spec/unit/persistence/mongoid_persistence_multiple_spec.rb:92

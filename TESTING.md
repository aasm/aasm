## Install dependency matrix

    appraisal install

This will re-generate Gemfiles in `gemfile` folder

Use rvm gemsets or similar to avoid global gem pollution

## Run specs

For all supported Rails/ORM combinations:

    appraisal rspec

Or for s specific one:

    appraisal rails_4.2 rspec

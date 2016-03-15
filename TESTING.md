## Install dependency matrix

    appraise install

This will re-generate Gemfiles in `gemfile` folder

Use rvm gemsets or similar to avoid global gem pollution

## Run specs

For all supported Rails/ORM combinations:

    appraise rspec

Or for s specific one:

    appraise rails_4.2 rspec
